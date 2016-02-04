require 'sidekiq/pool/cli'

RSpec.describe Sidekiq::Pool::CLI do
  let(:cli) { described_class.new }

  describe '#parse' do
    subject { cli.parse(args) }

    context 'without pool size' do
      let(:args) { ['sidekiq-pool', '-r', './spec/fake_env.rb'] }

      it 'requires pool size' do
        expect { subject }.to raise_error(ArgumentError, /Please specify pool size/)
      end
    end

    context 'with pool size' do
      before do
        cli.parse(['sidekiq-pool', '--pool-size', pool_size.to_s, '-r', './spec/fake_env.rb'])
      end

      let(:pool_size) { 3 }

      it 'sets pool size' do
        expect(cli.instance_variable_get(:@pool_size)).to eq pool_size
      end
    end
  end
end
