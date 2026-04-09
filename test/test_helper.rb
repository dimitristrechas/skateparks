unless ENV['DISABLE_SIMPLECOV']
  require 'simplecov'

  # Rails parallel workers use `Kernel.fork`, not `Process.fork`, so SimpleCov's
  # `enable_for_subprocesses` hook never runs. `parallelize_setup` runs inside each
  # forked worker and restarts coverage with a unique command name so results merge
  # instead of overwriting the coordinator's entry in `.resultset.json`.

  SimpleCov.start 'rails' do
    add_filter '/test/'
    minimum_coverage 80
    # Parent process when using process parallelization; workers set their own names below.
    command_name 'Minitest coordinator'
  end
end

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'mocha/minitest'

abort('The Rails environment is running in production mode!') if Rails.env.production?

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

Rails.root.glob('test/support/**/*.rb').sort.each { |f| require f }

module ActiveSupport
  class TestCase
    unless ENV['DISABLE_SIMPLECOV']
      parallelize_setup do |worker|
        SimpleCov.command_name "Minitest worker #{worker}"
        SimpleCov.print_error_status = false
        SimpleCov.formatter SimpleCov::Formatter::SimpleFormatter
        SimpleCov.minimum_coverage 0
        SimpleCov.start 'rails'
      end
    end

    parallelize(workers: :number_of_processors)

    fixtures :all
    self.use_transactional_tests = true
    self.fixture_paths = [Rails.root.join('test/fixtures')]

    include FactoryBot::Syntax::Methods
    include ActionDispatch::TestProcess::FixtureFile
  end
end

module ActionDispatch
  class IntegrationTest
    def login_as(user)
      session_record = user.sessions.create!(
        user_agent: 'Test',
        ip_address: '127.0.0.1',
        expires_at: 2.weeks.from_now
      )
      # GET before env_config: lazy route loading mid-allocation causes a GC
      # write-barrier violation (segfault). Routes must be fully loaded first.
      get new_session_url
      env = Rails.application.env_config.merge('HTTP_HOST' => 'test.host')
      request = ActionDispatch::Request.new(env)
      jar = ActionDispatch::Cookies::CookieJar.build(request, {})
      jar.signed[:session_token] = { value: session_record.session_token, httponly: true }
      cookies[:session_token] = jar[:session_token]
    end
  end
end

Rails.application.routes.default_url_options[:host] = 'http://test.host'
