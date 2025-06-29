require "rake"

class SitemapWorker
  include Sidekiq::Worker

  def perform
    ensure_public_directory
    Rails.application.load_tasks
    Rake::Task['sitemap:refresh'].invoke
  end

  def ensure_public_directory
    FileUtils.mkdir_p(Rails.public_path)
    FileUtils.chmod(0755, Rails.public_path)
  end
end
