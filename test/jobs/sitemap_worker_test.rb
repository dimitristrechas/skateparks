require 'test_helper'

class SitemapWorkerTest < ActiveSupport::TestCase
  def setup
    @worker = SitemapWorker.new
  end

  def test_perform_ensures_public_directory_exists
    rake_task = mock
    rake_task.expects(:invoke)
    @worker.expects(:ensure_public_directory)
    Rails.application.expects(:load_tasks)
    Rake::Task.expects(:[]).with('sitemap:refresh:no_ping').returns(rake_task)

    @worker.perform
  end

  def test_perform_loads_rake_tasks
    rake_task = mock
    rake_task.expects(:invoke)
    @worker.stubs(:ensure_public_directory)
    Rails.application.expects(:load_tasks)
    Rake::Task.stubs(:[]).returns(rake_task)

    @worker.perform
  end

  def test_perform_invokes_sitemap_refresh_task
    rake_task = mock
    rake_task.expects(:invoke)
    @worker.stubs(:ensure_public_directory)
    Rails.application.stubs(:load_tasks)
    Rake::Task.expects(:[]).with('sitemap:refresh:no_ping').returns(rake_task)

    @worker.perform
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
