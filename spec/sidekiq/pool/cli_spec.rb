require 'sidekiq/pool/cli'

RSpec.describe Sidekiq::Pool::CLI do
  let(:cli) { described_class.new }
  let(:mock_config) { './spec/sidekiq/pool/fake_config.yml' }

  describe '#parse_config_file' do
    subject { cli.parse_config_file(mock_config) }

    context 'without valid config' do
      let(:config) { ':workers: -' }

      before do
        allow(File).to receive(:read).and_return(config)
      end
      it 'raises an exception' do
        expect { subject }.to raise_error
      end
    end

    context 'with valid config' do
      let(:result) { { workers: [{ command: "-q default -q high", amount: 2}] } }

      it 'returns the parsed config' do
        expect(subject).to eq result
      end
    end
  end
end
