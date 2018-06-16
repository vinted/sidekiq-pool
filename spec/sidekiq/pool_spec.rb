describe Sidekiq::Pool do
  describe '.after_fork_hooks' do
    subject { described_class.after_fork_hooks }

    it { is_expected.to be_instance_of(Array) }
    it { is_expected.to be_empty }

    context 'when hooks are configured' do
      before do
        described_class.after_fork {}
        described_class.after_fork {}
      end

      after do
        described_class.after_fork_hooks.clear
      end

      it { is_expected.to contain_exactly(instance_of(Proc), instance_of(Proc)) }
    end
  end
end
