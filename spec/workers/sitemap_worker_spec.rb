require 'rails_helper'

RSpec.describe SitemapWorker, type: :worker do
  describe '#perform' do
    let(:worker) { described_class.new }
    let(:rake_task) { instance_double(Rake::Task) }

    before do
      allow(worker).to receive(:ensure_public_directory)
      allow(Rails.application).to receive(:load_tasks)
      allow(Rake::Task).to receive(:[]).with('sitemap:refresh:no_ping').and_return(rake_task)
      allow(rake_task).to receive(:invoke)
    end

    it 'ensures public directory exists' do
      worker.perform

      expect(worker).to have_received(:ensure_public_directory)
    end

    it 'loads rake tasks' do
      worker.perform

      expect(Rails.application).to have_received(:load_tasks)
    end

    it 'invokes sitemap refresh task' do
      worker.perform

      expect(rake_task).to have_received(:invoke)
    end
  end

  describe '#ensure_public_directory' do
    let(:worker) { described_class.new }
    let(:public_path) { Rails.public_path }

    before do
      allow(FileUtils).to receive(:mkdir_p)
      allow(FileUtils).to receive(:chmod)
    end

    it 'creates public directory' do
      worker.ensure_public_directory

      expect(FileUtils).to have_received(:mkdir_p).with(public_path)
    end

    it 'sets directory permissions to 755' do
      worker.ensure_public_directory

      expect(FileUtils).to have_received(:chmod).with(0o755, public_path)
    end
  end

  describe 'sidekiq configuration' do
    it 'includes Sidekiq::Worker' do
      expect(described_class.included_modules).to include(Sidekiq::Worker)
    end
  end
end
