class SitemapWorker
  include Sidekiq::Worker

  CONFIG_FILE = Rails.root.join('config/sitemap.rb').to_s

  def perform
    ensure_public_directory
    SitemapGenerator::Interpreter.run(config_file: CONFIG_FILE, verbose: false)
  end

  def ensure_public_directory
    FileUtils.mkdir_p(Rails.public_path)
    FileUtils.chmod(0o755, Rails.public_path)
  end
end
