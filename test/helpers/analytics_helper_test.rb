require 'test_helper'

class AnalyticsHelperTest < ActionView::TestCase
  tests AnalyticsHelper

  def test_cookie_consent_enabled_false_on_admin_path
    stubs(:request).returns(stub(path: '/admin'))

    with_posthog_key('phc_test') do
      assert_not cookie_consent_enabled?
    end
  end

  def test_cookie_consent_enabled_false_when_api_key_blank
    stubs(:request).returns(stub(path: '/about'))

    with_posthog_key(nil) do
      assert_not cookie_consent_enabled?
    end
  end

  def test_cookie_consent_enabled_true_with_key_on_public_path
    stubs(:request).returns(stub(path: '/about'))

    with_posthog_key('phc_test') do
      assert_predicate self, :cookie_consent_enabled?
    end
  end

  def test_posthog_enabled_false_on_admin_path
    stubs(:request).returns(stub(path: '/admin'))
    in_production do
      with_posthog_key('phc_test') do
        assert_not posthog_enabled?
      end
    end
  end

  def test_posthog_enabled_false_when_api_key_blank
    stubs(:request).returns(stub(path: '/about'))
    in_production do
      with_posthog_key(nil) do
        assert_not posthog_enabled?
      end
    end
  end

  def test_posthog_enabled_false_outside_production
    stubs(:request).returns(stub(path: '/about'))

    with_posthog_key('phc_test') do
      assert_not posthog_enabled?
    end
  end

  def test_posthog_enabled_true_in_production_with_key_on_public_path
    stubs(:request).returns(stub(path: '/about'))
    in_production do
      with_posthog_key('phc_test') do
        assert_predicate self, :posthog_enabled?
      end
    end
  end

  private

  def in_production
    Rails.env.stubs(:production?).returns(true)
    yield
  end

  def with_posthog_key(value)
    previous = ENV.fetch('POSTHOG_API_KEY', nil)
    if value.present?
      ENV['POSTHOG_API_KEY'] = value
    else
      ENV.delete('POSTHOG_API_KEY')
    end
    yield
  ensure
    if previous.present?
      ENV['POSTHOG_API_KEY'] = previous
    else
      ENV.delete('POSTHOG_API_KEY')
    end
  end
end
