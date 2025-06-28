class SitemapWorker
  include Sidekiq::Worker

  def perform
    Rake::Task['sitemap:refresh'].invoke
  end
end
