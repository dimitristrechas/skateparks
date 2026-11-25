require 'test_helper'

class SitemapWorkerTest < ActiveSupport::TestCase
  def setup
    @worker = SitemapWorker.new
  end

  def test_perform_ensures_public_directory_exists
    SitemapGenerator::Interpreter.stubs(:run)
    @worker.expects(:ensure_public_directory)

    @worker.perform
  end

  def test_perform_runs_sitemap_generator_with_config_file
    @worker.stubs(:ensure_public_directory)
    SitemapGenerator::Interpreter.expects(:run)
                                 .with(config_file: Rails.root.join('config/sitemap.rb').to_s, verbose: false)

    @worker.perform
  end

  def test_perform_regenerates_on_every_run_in_same_process
    @worker.stubs(:ensure_public_directory)
    SitemapGenerator::Interpreter.expects(:run).twice

    2.times { SitemapWorker.new.tap { |worker| worker.stubs(:ensure_public_directory) }.perform }
  end

  def test_ensure_public_directory_creates_directory
    public_path = Rails.public_path
    FileUtils.expects(:mkdir_p).with(public_path)
    FileUtils.expects(:chmod).with(0o755, public_path)

    @worker.ensure_public_directory
  end

  def test_ensure_public_directory_sets_permissions_to_755 # rubocop:disable Naming/VariableNumber
    public_path = Rails.public_path
    FileUtils.stubs(:mkdir_p)
    FileUtils.expects(:chmod).with(0o755, public_path)

    @worker.ensure_public_directory
  end

  def test_includes_sidekiq_worker
    assert_includes SitemapWorker.included_modules, Sidekiq::Worker
  end
end
