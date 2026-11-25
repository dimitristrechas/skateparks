require 'test_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  SCREEN_SIZE = [1400, 1000].freeze

  # Docker (`sh scripts.sh test --system`): Chrome runs in the skateparks-chrome container,
  # so the Capybara server must listen on all interfaces and be addressed by container IP.
  # CI / host: local headless Chrome.
  if (remote_url = ENV.fetch('SELENIUM_REMOTE_URL', nil))
    driven_by :selenium, using: :headless_chrome, screen_size: SCREEN_SIZE,
                         options: { browser: :remote, url: remote_url }

    Capybara.server_host = '0.0.0.0'
    Capybara.always_include_port = true
    Capybara.app_host = "http://#{IPSocket.getaddress(Socket.gethostname)}"
  else
    driven_by :selenium, using: :headless_chrome, screen_size: SCREEN_SIZE
  end

  private

  def sign_in_as(user, password: 'password123456')
    visit new_session_path
    fill_in I18n.t('sessions.email_label'), with: user.email_address
    fill_in I18n.t('sessions.password_label'), with: password
    click_on I18n.t('sessions.submit')

    assert_no_current_path new_session_path
  end

  def localized_path(path, locale)
    locale.to_s == I18n.default_locale.to_s ? path : "#{path}?locale=#{locale}"
  end
end
