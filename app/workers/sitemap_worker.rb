require 'rake'

class SitemapWorker
  include Sidekiq::Worker

  def perform
    ensure_public_directory
    Rails.application.load_tasks
    Rake::Task['sitemap:refresh:no_ping'].invoke
  end

  def ensure_public_directory
    FileUtils.mkdir_p(Rails.public_path)
    FileUtils.chmod(0o755, Rails.public_path)
  end
end
