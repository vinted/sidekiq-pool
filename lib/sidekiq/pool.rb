require 'sidekiq/pool/version'

module Sidekiq
  module Pool
    module_function

    def after_fork(&block)
      @after_fork_hooks ||= []
      @after_fork_hooks << block
    end

    def after_fork_hooks
      @after_fork_hooks
    end
  end
end
