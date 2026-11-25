require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::TimeHelpers

  def setup
    @published_skatepark = create(:skatepark)
    Rails.cache.clear
  end

  def test_get_index_returns_success
    get root_path

    assert_response :success
  end

  def test_get_index_excludes_unpublished_popular_skateparks
    draft_skatepark = create(:skatepark, :draft)
    create(:popular_skatepark, skatepark: draft_skatepark)
    create(:popular_skatepark, skatepark: @published_skatepark)

    get root_path

    assert_equal [@published_skatepark], assigns(:skateparks_popular)
  end

  def test_get_index_reflects_renamed_skatepark_after_cache_was_filled
    get root_path
    @published_skatepark.update!(name_en: 'Renamed Park')

    get root_path

    assert_includes response.body, 'Renamed Park'
  end

  def test_get_index_renders_translated_header_logo_alt_per_locale
    get root_path

    assert_response :success
    assert_includes response.body, I18n.t('home.logo_alt', locale: 'en')

    get root_path(locale: 'el')

    assert_response :success
    assert_includes response.body, I18n.t('home.logo_alt', locale: 'el')
  end

  def test_get_index_renders_translated_theme_toggle_aria_label_per_locale
    get root_path

    assert_response :success
    assert_includes response.body, I18n.t('home.theme_toggle_aria_label', locale: 'en')

    get root_path(locale: 'el')

    assert_response :success
    assert_includes response.body, I18n.t('home.theme_toggle_aria_label', locale: 'el')
  end

  def test_get_index_renders_developer_navigation_outside_production
    get root_path

    assert_response :success
    assert_includes response.body, I18n.t('home.developer_navigation.admin')
    assert_includes response.body, admin_root_path
    assert_not_includes response.body, I18n.t('home.developer_navigation.lookbook')
  end

  def test_get_index_hides_developer_navigation_in_production
    Rails.env.stubs(:production?).returns(true)

    get root_path

    assert_response :success
    assert_not_includes response.body, I18n.t('home.developer_navigation.admin')
    assert_not_includes response.body, I18n.t('home.developer_navigation.lookbook')
  end

  def test_get_index_assigns_skateparks_latest_from_cache
    get root_path

    assert_instance_of Array, assigns(:skateparks_latest)
  end

  def test_get_index_caches_skateparks_latest
    get root_path

    cached_value = Rails.cache.read(Skatepark.homepage_latest_cache_key)

    assert_equal assigns(:skateparks_latest), cached_value
  end

  def test_get_index_uses_cached_skateparks_latest_on_subsequent_requests
    get root_path
    first_result = assigns(:skateparks_latest)

    get root_path
    second_result = assigns(:skateparks_latest)

    assert_equal first_result, second_result
  end

  def test_get_index_assigns_skateparks_popular_from_cache
    create(:popular_skatepark, skatepark: @published_skatepark)

    get root_path

    assert_instance_of Array, assigns(:skateparks_popular)
  end

  def test_get_index_caches_skateparks_popular
    create(:popular_skatepark, skatepark: @published_skatepark)

    get root_path

    cached_value = Rails.cache.read(Skatepark.homepage_popular_cache_key)

    assert_equal assigns(:skateparks_popular), cached_value
  end

  def test_get_index_uses_cached_skateparks_popular_on_subsequent_requests
    create(:popular_skatepark, skatepark: @published_skatepark)

    get root_path
    first_result = assigns(:skateparks_popular)

    get root_path
    second_result = assigns(:skateparks_popular)

    assert_equal first_result, second_result
  end

  def test_get_about_returns_success
    get about_path

    assert_response :success
  end

  def test_get_about_assigns_title_and_meta_description
    get about_path

    assert_equal I18n.t('about.title'), assigns(:title)
    assert_equal I18n.t('about_details'), assigns(:meta_description)
  end

  def test_get_about_renders_default_locale_social_tags_with_el_locale
    get about_path(locale: :el)

    assert_response :success
    english_title = CGI.escapeHTML(I18n.t('about.title', locale: :en))
    english_description = CGI.escapeHTML(I18n.t('about_details', locale: :en))

    assert_includes response.body, %(property="og:title" content="#{english_title}")
    assert_includes response.body, %(property="og:description" content="#{english_description}")
    assert_includes response.body, 'property="og:locale" content="en_US"'
  end

  def test_get_contact_returns_success
    get contact_path

    assert_response :success
  end

  def test_get_contact_assigns_title_and_meta_description
    get contact_path

    assert_equal I18n.t('contact'), assigns(:title)
    assert_equal I18n.t('contact_details'), assigns(:meta_description)
  end

  def test_get_privacy_returns_success
    get privacy_path

    assert_response :success
  end

  def test_get_privacy_assigns_title_and_meta_description
    get privacy_path

    assert_equal I18n.t('privacy.title'), assigns(:title)
    assert_equal I18n.t('privacy.meta_description'), assigns(:meta_description)
  end

  def test_get_privacy_renders_consent_status_when_cookie_consent_enabled
    with_posthog_key('phc_test') do
      get privacy_path

      assert_response :success
      assert_includes response.body, 'data-posthog-target="consentStatus"'
      assert_includes response.body, 'data-current-choice-label='
      assert_predicate %w[status_accepted status_rejected status_not_set], :all? do |key|
        response.body.include?(I18n.t("cookie_consent.#{key}"))
      end
    end
  end

  def test_get_index_renders_go_skate_day_countdown_during_visibility_window
    travel_to Time.zone.local(2026, 5, 21, 12) do
      get root_path

      assert_response :success
      assert_includes response.body, I18n.t('home.go_skate_day.countdown', count: 31)
    end
  end

  def test_get_index_renders_singular_go_skate_day_countdown_on_june_twentieth
    travel_to Time.zone.local(2026, 6, 20, 12) do
      get root_path

      assert_response :success
      assert_includes response.body, I18n.t('home.go_skate_day.countdown', count: 1)
    end
  end

  def test_get_index_renders_go_skate_day_celebration_on_june_twenty_first
    travel_to Time.zone.local(2026, 6, 21, 12) do
      get root_path

      assert_response :success
      assert_includes response.body, 'Go Skate Day!'
      assert_includes response.body, CGI.escapeHTML(I18n.t('home.go_skate_day.today'))
    end
  end

  def test_get_index_hides_go_skate_day_countdown_before_visibility_window
    travel_to Time.zone.local(2026, 5, 20, 12) do
      get root_path

      assert_response :success
      assert_not_includes response.body, I18n.t('home.go_skate_day.countdown', count: 32)
      assert_not_includes response.body, I18n.t('home.go_skate_day.today')
    end
  end

  def test_get_index_hides_go_skate_day_countdown_after_visibility_window
    travel_to Time.zone.local(2026, 6, 22, 12) do
      get root_path

      assert_response :success
      assert_not_includes response.body, I18n.t('home.go_skate_day.today')
    end
  end

  def test_get_index_renders_visible_site_announcement
    announcement = create(:site_announcement, message_en: 'Homepage news item', message_el: 'Νέα αρχικής')

    get root_path

    assert_response :success
    assert_includes response.body, announcement.message_en
    assert_includes response.body, 'id="site-announcements-region"'
  end

  def test_get_index_hides_unpublished_site_announcement
    create(:site_announcement, :draft, message_en: 'Hidden draft news')

    get root_path

    assert_response :success
    assert_not_includes response.body, 'Hidden draft news'
  end

  def test_get_privacy_renders_updated_cookies_body_in_english
    get privacy_path

    assert_response :success
    assert_includes response.body, I18n.t('privacy.cookies_body', locale: :en)
    assert_includes response.body, I18n.t('privacy.rights_body', locale: :en)
  end

  def test_get_privacy_renders_updated_cookies_body_in_greek
    get privacy_path(locale: :el)

    assert_response :success
    assert_includes response.body, I18n.t('privacy.cookies_body', locale: :el)
    assert_includes response.body, I18n.t('privacy.rights_body', locale: :el)
  end

  private

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
