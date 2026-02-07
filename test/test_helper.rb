require 'coverage'
Coverage.start(:all)

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

Rails.application.routes.default_url_options[:host] = 'http://test.host'
