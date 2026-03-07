unless ENV['DISABLE_SIMPLECOV']
  require 'simplecov'
  SimpleCov.start 'rails' do
    add_filter '/test/'
    minimum_coverage 80
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
