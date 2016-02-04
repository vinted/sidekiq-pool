require 'sidekiq/cli'

module Sidekiq
  module Pool
    class CLI < Sidekiq::CLI
      def initialize
        @master_pid = ::Process.pid
        @child_index = 0
        @pool = []
        super
      end

      alias_method :run_child, :run

      def run
        logger.info "Starting pool with #{@pool_size} instances"
        trap_signals

        @pool_size.times { fork_child }

        wait_for_signals
      end

      private

      def parse_options(argv)
        opts = {}

        @parser = OptionParser.new do |o|
          o.on '--pool-size INT', "pool size" do |arg|
            @pool_size = Integer(arg)
          end

          o.on '-c', '--concurrency INT', "processor threads to use" do |arg|
            opts[:concurrency] = Integer(arg)
          end

          o.on '-d', '--daemon', "Daemonize process" do |arg|
            opts[:daemon] = arg
          end

          o.on '-e', '--environment ENV', "Application environment" do |arg|
            opts[:environment] = arg
          end

          o.on '-g', '--tag TAG', "Process tag for procline" do |arg|
            opts[:tag] = arg
          end

          o.on "-q", "--queue QUEUE[,WEIGHT]", "Queues to process with optional weights" do |arg|
            queue, weight = arg.split(",")
            parse_queue opts, queue, weight
          end

          o.on '-r', '--require [PATH|DIR]', "Location of Rails application with workers or file to require" do |arg|
            opts[:require] = arg
          end

          o.on '-t', '--timeout NUM', "Shutdown timeout" do |arg|
            opts[:timeout] = Integer(arg)
          end

          o.on "-v", "--verbose", "Print more verbose output" do |arg|
            opts[:verbose] = arg
          end

          o.on '-C', '--config PATH', "path to YAML config file" do |arg|
            opts[:config_file] = arg
          end

          o.on '-L', '--logfile PATH', "path to writable logfile" do |arg|
            opts[:logfile] = arg
          end

          o.on '-P', '--pidfile PATH', "path to pidfile" do |arg|
            opts[:pidfile] = arg
          end

          o.on '-V', '--version', "Print version and exit" do |arg|
            puts "Sidekiq #{Sidekiq::VERSION}"
            die(0)
          end
        end

        @parser.banner = 'sidekiq-pool [options]'
        @parser.on_tail '-h', '--help', 'Show help' do
          logger.info @parser
          die 1
        end
        @parser.parse!(argv)

        %w[config/sidekiq.yml config/sidekiq.yml.erb].each do |filename|
          opts[:config_file] ||= filename if File.exist?(filename)
        end

        opts
      end

      def validate!
        raise ArgumentError, 'Please specify pool size using --pool-size N' unless @pool_size
        super
      end

      def trap_signals
        @self_read, @self_write = IO.pipe

        %w(INT TERM USR1 USR2 TTIN TTOU CLD).each do |sig|
          begin
            trap sig do
              @self_write.puts(sig) unless fork?
            end
          rescue ArgumentError
            puts "Signal #{sig} not supported"
          end
        end
      end

      def fork_child
        @pool << fork do
          @self_write.close
          options[:index] = @child_index++
          run_child
        end
      end

      def wait_for_signals
        while readable_io = IO.select([@self_read])
          signal = readable_io.first[0].gets.strip
          handle_master_signal(signal)
        end
      end

      def handle_master_signal(sig)
        case sig
        when 'INT', 'TERM'
          stop_children
          logger.info 'Bye!'
          exit(0)
        when 'TTIN'
          add_child
        when 'TTOU'
          remove_child
        when 'CLD'
          check_pool
        when 'USR1', 'USR2'
          logger.info "Sending #{sig} signal to the pool"
          signal_to_pool(sig)
        end
      end

      def add_child
        logger.info 'Adding child'
        fork_child
      end

      def remove_child
        return if @pool.empty?

        if @pool.size == 1
          logger.info 'Cowardly refusing to kill the last child'
          return
        end

        logger.info 'Removing child'
        signal_to_child('TERM', @pool.shift)
      end

      def signal_to_pool(sig)
        @pool.each { |pid| signal_to_child(sig, pid) }
      end

      def signal_to_child(sig, pid)
        ::Process.kill(sig, pid)
      rescue Errno::ESRCH
        @pool.delete(pid)
      end

      def check_pool
        @pool.each do |pid|
          next if alive?(pid)
          handle_dead_child(pid)
        end
      end

      def handle_dead_child(pid)
        logger.info "Child #{pid} died"
        @pool.delete(pid)
        add_child
      end

      def alive?(pid)
        ::Process.getpgid(pid)
        true
      rescue Errno::ESRCH
        false
      end

      def stop_children
        logger.info 'Stopping children'

        loop do
          signal_to_pool('TERM')
          sleep(1)
          break if @pool.none? { |pid| alive?(pid) }
        end
      end

      def fork?
        ::Process.pid != @master_pid
      end
    end
  end
end
