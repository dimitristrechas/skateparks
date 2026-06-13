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

  def test_get_index_assigns_only_published_skateparks
    draft_skatepark = create(:skatepark, :draft)
    archived_skatepark = create(:skatepark, :archived)

    get root_path
    skateparks = assigns(:skateparks).to_a

    assert_includes skateparks, @published_skatepark
    assert_not_includes skateparks, draft_skatepark
    assert_not_includes skateparks, archived_skatepark
  end

  def test_get_index_orders_skateparks_by_created_at_desc # rubocop:disable Metrics/AbcSize
    older_skatepark = create(:skatepark)
    older_skatepark.update_column(:created_at, 2.days.ago) # rubocop:disable Rails/SkipsModelValidations
    newer_skatepark = create(:skatepark)
    newer_skatepark.update_column(:created_at, 1.day.ago) # rubocop:disable Rails/SkipsModelValidations

    get root_path
    skateparks = assigns(:skateparks).to_a

    # Check that our three test skateparks are in the correct order
    published_index = skateparks.index(@published_skatepark)
    newer_index = skateparks.index(newer_skatepark)
    older_index = skateparks.index(older_skatepark)

    assert_not_nil published_index
    assert_not_nil newer_index
    assert_not_nil older_index
    assert_operator published_index, :<, newer_index, 'Most recent should come before newer'
    assert_operator newer_index, :<, older_index, 'Newer should come before older'
  end

  def test_get_index_assigns_locale_from_params
    get root_path(locale: 'el')

    assert_equal 'el', assigns(:locale)
  end

  def test_get_index_renders_translated_header_logo_alt_per_locale
    get root_path(locale: 'en')

    assert_response :success
    assert_includes response.body, I18n.t('home.logo_alt', locale: 'en')

    get root_path(locale: 'el')

    assert_response :success
    assert_includes response.body, I18n.t('home.logo_alt', locale: 'el')
  end

  def test_get_index_renders_translated_theme_toggle_aria_label_per_locale
    get root_path(locale: 'en')

    assert_response :success
    assert_includes response.body, I18n.t('home.theme_toggle_aria_label', locale: 'en')

    get root_path(locale: 'el')

    assert_response :success
    assert_includes response.body, I18n.t('home.theme_toggle_aria_label', locale: 'el')
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

    assert_equal I18n.t('about'), assigns(:title)
    assert_equal I18n.t('about_details'), assigns(:meta_description)
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

  def test_get_index_renders_go_skate_day_countdown_during_visibility_window
    travel_to Time.zone.local(2026, 5, 21, 12) do
      get root_path

      assert_response :success
      assert_includes response.body, I18n.t('home.go_skate_day.countdown', count: 31)
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
end
