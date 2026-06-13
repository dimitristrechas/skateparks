require 'test_helper'

class CookieConsentBannerComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers

  def test_renders_message_and_buttons_in_english
    I18n.with_locale(:en) do
      render_inline(CookieConsentBannerComponent.new)

      assert_selector '[role="region"]', text: I18n.t('cookie_consent.message')
      assert_selector 'button', text: I18n.t('cookie_consent.accept')
      assert_selector 'button', text: I18n.t('cookie_consent.reject')
    end
  end

  def test_renders_message_and_buttons_in_greek
    I18n.with_locale(:el) do
      render_inline(CookieConsentBannerComponent.new)

      assert_selector '[role="region"]', text: I18n.t('cookie_consent.message')
      assert_selector 'button', text: I18n.t('cookie_consent.accept')
      assert_selector 'button', text: I18n.t('cookie_consent.reject')
    end
  end

  def test_includes_region_aria_label_and_posthog_target
    render_inline(CookieConsentBannerComponent.new)

    assert_selector "[role='region'][aria-label='#{I18n.t('cookie_consent.aria_label')}']"
    assert_selector '[data-posthog-target="banner"]'
  end

  def test_wires_buttons_to_posthog_stimulus_actions
    render_inline(CookieConsentBannerComponent.new)

    assert_selector "button[data-action='click->posthog#accept']"
    assert_selector "button[data-action='click->posthog#reject']"
  end

  def test_renders_learn_more_link_to_privacy_page
    render_inline(CookieConsentBannerComponent.new)

    assert_selector "a[href='#{privacy_path(locale: I18n.locale)}']", text: I18n.t('cookie_consent.learn_more')
  end

  def test_banner_is_hidden_by_default
    render_inline(CookieConsentBannerComponent.new)

    assert_selector '[data-posthog-target="banner"].hidden'
  end
end
