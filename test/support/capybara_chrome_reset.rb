# Chrome 158+ rejects the '*' origin Capybara 3.40 passes to Storage.clearDataForOrigin in reset!.
# Mirrors https://github.com/teamcapybara/capybara/pull/2868; delete once a Capybara release includes it.
require 'capybara'
require 'capybara/selenium/driver'
require 'capybara/selenium/driver_specializations/chrome_driver'

module CapybaraChromeReset
  private

  def execute_cdp(cmd, params = {})
    super
  rescue Selenium::WebDriver::Error::InvalidArgumentError
    raise unless cmd == 'Storage.clearDataForOrigin' && params[:origin] == '*'

    super('Network.clearBrowserCookies')
    origin = app_origin
    super('Storage.clearDataForOrigin', origin: origin, storageTypes: 'local_storage') if origin
  end

  def app_origin
    server = Capybara.current_session.server
    return unless server

    Capybara.app_host ? "#{Capybara.app_host}:#{server.port}" : server.base_url
  end
end

Capybara::Selenium::Driver::ChromeDriver.prepend(CapybaraChromeReset)
