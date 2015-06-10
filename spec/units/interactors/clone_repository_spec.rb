require 'spec_helper'

RSpec.describe Pulsar::CloneRepository do
  subject { described_class.new }

  it { is_expected.to be_kind_of(Interactor) }

  describe '.call' do
    subject { described_class.call(repository: repo, repository_type: type) }

    let(:repo) { './my-conf' }

    context 'success' do
      let(:tmp_path)   { Pulsar::PULSAR_TMP }
      let(:tmp_config) { /#{tmp_path}\/conf-\d+\.\d+/ }

      before { expect(FileUtils).to receive(:mkdir_p).with(tmp_path).ordered }

      context 'when repository_type is :local_folder' do
        let(:type) { :local_folder }

        before do
          expect(FileUtils).to receive(:cp_r).with(repo, tmp_config).ordered
        end

        it { is_expected.to be_a_success }
      end

      context 'when repository_type is a :local_git' do
        let(:type) { :local_git }

        before do
          expect(Rake).to receive(:sh)
            .with(/git clone #{repo} #{tmp_config}/).ordered

          expect(FileUtils).to receive(:cp_r).with(repo, tmp_config).ordered
        end

        it { is_expected.to be_a_success }
      end
    end

    context 'failure' do
      context 'when no repository context is passed' do
        subject { described_class.call(repository_type: :something) }

        it { is_expected.to be_a_failure }
      end

      context 'when no repository_type context is passed' do
        subject { described_class.call(repository: './some-path') }

        it { is_expected.to be_a_failure }
      end

      context 'when an exception is triggered' do
        let(:type) { :local_folder }

        before { allow(FileUtils).to receive(:cp_r).and_raise(RuntimeError) }

        it { is_expected.to be_a_failure }
      end
    end
  end
end
