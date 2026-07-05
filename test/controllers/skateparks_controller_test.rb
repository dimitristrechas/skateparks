require 'test_helper'

class SkateparksControllerTest < ActionDispatch::IntegrationTest
  include ActionView::Helpers::SanitizeHelper
  include Rails.application.routes.url_helpers

  def setup
    Rails.cache.clear
    @skatepark = create(:skatepark)
  end

  def test_get_index_returns_success_and_assigns_skateparks
    get skateparks_path

    assert_response :success
    assert_includes assigns(:skateparks), @skatepark
  end

  def test_get_index_shows_only_published_skateparks
    published_skatepark = create(:skatepark)
    draft_skatepark = create(:skatepark, :draft)
    archived_skatepark = create(:skatepark, :archived)

    get skateparks_path

    assert_includes assigns(:skateparks), published_skatepark
    assert_not_includes assigns(:skateparks), draft_skatepark
    assert_not_includes assigns(:skateparks), archived_skatepark
  end

  def test_get_index_filters_by_country_code
    greece_skatepark = create(:skatepark, country_code: 'GR')
    us_skatepark = create(:skatepark, :us_location)

    get skateparks_path(country_code: 'US')

    assert_includes assigns(:skateparks), us_skatepark
    assert_not_includes assigns(:skateparks), greece_skatepark
  end

  def test_get_index_filters_by_country_code_and_state
    california_skatepark = create(:skatepark, country_code: 'US', state: 'CA')
    texas_skatepark = create(:skatepark, country_code: 'US', state: 'TX')
    greece_skatepark = create(:skatepark, country_code: 'GR')

    get skateparks_path(country_code: 'US', state: 'CA')

    assert_includes assigns(:skateparks), california_skatepark
    assert_not_includes assigns(:skateparks), texas_skatepark
    assert_not_includes assigns(:skateparks), greece_skatepark
  end

  def test_get_index_ignores_state_filter_when_country_code_missing
    california_skatepark = create(:skatepark, country_code: 'US', state: 'CA')
    texas_skatepark = create(:skatepark, country_code: 'US', state: 'TX')
    greece_skatepark = create(:skatepark, country_code: 'GR')

    get skateparks_path(state: 'CA')

    assert_includes assigns(:skateparks), california_skatepark
    assert_includes assigns(:skateparks), texas_skatepark
    assert_includes assigns(:skateparks), greece_skatepark
  end

  def test_get_index_returns_all_published_skateparks_with_no_filters
    greece_park = create(:skatepark)
    us_park = create(:skatepark, :us_location)

    get skateparks_path

    assert_includes assigns(:skateparks), greece_park
    assert_includes assigns(:skateparks), us_park
  end

  def test_get_index_accepts_page_parameter
    get skateparks_path(page: 2)

    assert_response :success
  end

  def test_get_index_returns_skateparks_in_alphabetical_order
    create(:skatepark, name_en: 'Zebra Park', name_el: 'Zebra Park')
    create(:skatepark, name_en: 'Alpha Park', name_el: 'Alpha Park')
    create(:skatepark, name_en: 'Middle Park', name_el: 'Middle Park')

    get skateparks_path
    names = assigns(:skateparks).map(&:name)

    assert_equal names.sort, names
  end

  def test_get_index_filters_by_distance
    nearby_skatepark = create_us_skatepark(name: 'Nearby Park', lat: 0.0, lng: 0.05)
    faraway_skatepark = create_us_skatepark(name: 'Faraway Park', lat: 0.0, lng: 0.5)

    get skateparks_path(country_code: 'US', lat: 0, lng: 0, distance: 10)

    assert_includes assigns(:skateparks), nearby_skatepark
    assert_not_includes assigns(:skateparks), faraway_skatepark
  end

  def test_get_index_orders_distance_results_by_nearest_first
    nearest_skatepark = create_us_skatepark(name: 'Nearest Park', lat: 0.0, lng: 0.05)
    middle_skatepark = create_us_skatepark(name: 'Middle Park', lat: 0.0, lng: 0.1)
    farthest_skatepark = create_us_skatepark(name: 'Farthest Park', lat: 0.0, lng: 0.2)

    get skateparks_path(country_code: 'US', lat: 0, lng: 0, distance: 25)

    assert_equal [nearest_skatepark.id, middle_skatepark.id, farthest_skatepark.id], assigns(:skateparks).map(&:id)
  end

  def test_get_index_combines_distance_country_and_state_filters
    california_skatepark = create_us_skatepark(name: 'California Park', lat: 0.0, lng: 0.05, state: 'CA')
    texas_skatepark = create_us_skatepark(name: 'Texas Park', lat: 0.0, lng: 0.05, state: 'TX')
    greece_skatepark = create(:skatepark, name_en: 'Greece Park', name_el: 'Greece Park', lat: 0.0, lng: 0.05)

    get skateparks_path(country_code: 'US', state: 'CA', lat: 0, lng: 0, distance: 25)

    assert_includes assigns(:skateparks), california_skatepark
    assert_not_includes assigns(:skateparks), texas_skatepark
    assert_not_includes assigns(:skateparks), greece_skatepark
  end

  def test_get_index_falls_back_to_alphabetical_order_when_distance_params_are_invalid
    create_us_skatepark(name: 'Zebra Park', lat: 0.0, lng: 0.05)
    create_us_skatepark(name: 'Alpha Park', lat: 0.0, lng: 0.15)
    create_us_skatepark(name: 'Middle Park', lat: 0.0, lng: 0.3)

    get skateparks_path(country_code: 'US', lat: 0, lng: 0, distance: 15)
    names = assigns(:skateparks).map(&:name)

    assert_equal names.sort, names
  end

  def test_get_index_falls_back_to_alphabetical_when_lat_missing
    create_us_skatepark(name: 'Zebra Park', lat: 0.0, lng: 0.05)
    create_us_skatepark(name: 'Alpha Park', lat: 0.0, lng: 0.15)

    get skateparks_path(country_code: 'US', lng: 0, distance: 10)
    names = assigns(:skateparks).map(&:name)

    assert_response :success
    assert_equal names.sort, names
  end

  def test_get_index_falls_back_to_alphabetical_when_lng_missing
    create_us_skatepark(name: 'Zebra Park', lat: 0.0, lng: 0.05)
    create_us_skatepark(name: 'Alpha Park', lat: 0.0, lng: 0.15)

    get skateparks_path(country_code: 'US', lat: 0, distance: 10)
    names = assigns(:skateparks).map(&:name)

    assert_response :success
    assert_equal names.sort, names
  end

  def test_get_index_falls_back_to_alphabetical_when_distance_missing
    create_us_skatepark(name: 'Zebra Park', lat: 0.0, lng: 0.05)
    create_us_skatepark(name: 'Alpha Park', lat: 0.0, lng: 0.15)

    get skateparks_path(country_code: 'US', lat: 0, lng: 0)
    names = assigns(:skateparks).map(&:name)

    assert_response :success
    assert_equal names.sort, names
  end

  def test_get_index_falls_back_to_alphabetical_with_non_numeric_coordinates
    create_us_skatepark(name: 'Zebra Park', lat: 0.0, lng: 0.05)
    create_us_skatepark(name: 'Alpha Park', lat: 0.0, lng: 0.15)

    get skateparks_path(country_code: 'US', lat: 'abc', lng: 'xyz', distance: 10)
    names = assigns(:skateparks).map(&:name)

    assert_response :success
    assert_equal names.sort, names
  end

  def test_get_index_falls_back_to_alphabetical_with_out_of_range_lat
    create_us_skatepark(name: 'Zebra Park', lat: 0.0, lng: 0.05)
    create_us_skatepark(name: 'Alpha Park', lat: 0.0, lng: 0.15)

    get skateparks_path(country_code: 'US', lat: 100, lng: 0, distance: 10)
    names = assigns(:skateparks).map(&:name)

    assert_response :success
    assert_equal names.sort, names
  end

  def test_get_index_falls_back_to_alphabetical_with_out_of_range_lng
    create_us_skatepark(name: 'Zebra Park', lat: 0.0, lng: 0.05)
    create_us_skatepark(name: 'Alpha Park', lat: 0.0, lng: 0.15)

    get skateparks_path(country_code: 'US', lat: 0, lng: 200, distance: 10)
    names = assigns(:skateparks).map(&:name)

    assert_response :success
    assert_equal names.sort, names
  end

  def test_get_index_assigns_distance_attribute_when_distance_filter_is_active
    nearby_skatepark = create_us_skatepark(name: 'Nearby Park', lat: 0.0, lng: 0.05)

    get skateparks_path(country_code: 'US', lat: 0, lng: 0, distance: 10)

    filtered_skatepark = assigns(:skateparks).find { |skatepark| skatepark.id == nearby_skatepark.id }

    assert_respond_to filtered_skatepark, :distance
    assert_not_nil filtered_skatepark.distance
  end

  def test_get_index_with_distance_avoids_n_plus_one_queries_for_listing_fields
    create_us_skatepark(name: 'Nearby Park', lat: 0.0, lng: 0.05)
    create_us_skatepark(name: 'Middle Park', lat: 0.0, lng: 0.1)
    create_us_skatepark(name: 'Far Park', lat: 0.0, lng: 0.2)

    queries = capture_sql_queries do
      get skateparks_path(country_code: 'US', lat: 0, lng: 0, distance: 25)
    end

    assert_operator count_matching_queries(queries, /mobility_string_translations/), :<=, 1
    assert_operator count_matching_queries(queries, /active_storage_attachments/), :<=, 1
    assert_operator count_matching_queries(queries, /active_storage_blobs/), :<=, 1
    assert_operator count_matching_queries(queries, /FROM "skatepark_images"/), :<=, 1
  end

  def test_get_index_assigns_countries_from_cache
    Rails.cache.clear
    create(:skatepark, country_code: 'GR')

    get skateparks_path

    assert_instance_of Array, assigns(:countries)
    assert_instance_of ISO3166::Country, assigns(:countries).first
  end

  def test_get_index_assigns_empty_states_when_no_country_selected
    get skateparks_path

    assert_equal [], assigns(:states)
  end

  def test_get_index_assigns_states_when_country_code_provided
    get skateparks_path(country_code: 'GR')

    assert_instance_of Array, assigns(:states)
  end

  def test_get_show_returns_success_and_assigns_skatepark
    get skatepark_path(@skatepark)

    assert_response :success
    assert_equal @skatepark, assigns(:skatepark)
  end

  def test_get_show_redirects_to_homepage_for_draft_skatepark
    draft_skatepark = create(:skatepark, :draft)

    get skatepark_path(draft_skatepark)

    assert_redirected_to root_path
    assert_equal I18n.t('skateparks.not_found'), flash[:alert]
  end

  def test_get_show_redirects_to_homepage_for_archived_skatepark
    archived_skatepark = create(:skatepark, :archived)

    get skatepark_path(archived_skatepark)

    assert_redirected_to root_path
    assert_equal I18n.t('skateparks.not_found'), flash[:alert]
  end

  def test_get_show_sets_meta_tags
    get skatepark_path(@skatepark)

    assert_equal "#{@skatepark.name} | Skateparks.gr", assigns(:title)
    assert_equal @skatepark.description.to_plain_text, assigns(:meta_description)
    assert_equal url_for(@skatepark.cover_image), assigns(:meta_image)
  end

  def test_get_show_redirects_to_homepage_when_skatepark_not_found
    get skatepark_path('nonexistent-id')

    assert_redirected_to root_path
    assert_equal I18n.t('skateparks.not_found'), flash[:alert]
  end

  def test_get_show_redirects_to_homepage_for_stale_slug
    get skatepark_path("#{@skatepark.id}-wrong-slug-name")

    assert_redirected_to root_path
    assert_equal I18n.t('skateparks.not_found'), flash[:alert]
  end

  def test_get_show_includes_videos_tab_when_no_active_videos
    get skatepark_path(@skatepark)

    assert_response :success
    assert_includes response.body, 'videos-tab'
    assert_includes response.body, I18n.t('skateparks.video_suggestion.cta')
    assert_includes response.body, 'video_suggestion_dialog'
  end

  def test_importmap_includes_video_suggestion_assets
    get root_path

    assert_response :success

    importmap_json = response.body[%r{type="importmap"[^>]*>(\{.*?\})</script>}m, 1]

    assert importmap_json, 'expected importmap script on page'

    imports = JSON.parse(importmap_json).fetch('imports')

    assert imports.key?('controllers/skatepark_video_suggestion_controller')
    assert imports.key?('lib/youtube_url')
  end

  def test_get_show_does_not_render_pending_videos
    create(:skatepark_video, :pending, skatepark: @skatepark, youtube_url: 'https://youtu.be/dQw4w9WgXcQ')

    get skatepark_path(@skatepark)

    assert_response :success
    assert_not_includes response.body, 'previewVideo-0'
  end

  def test_get_show_renders_active_videos_only
    create(:skatepark_video, skatepark: @skatepark, youtube_url: 'https://youtu.be/dQw4w9WgXcQ')
    create(:skatepark_video, :pending, skatepark: @skatepark, youtube_url: 'https://youtu.be/00000000001')

    get skatepark_path(@skatepark)

    assert_response :success
    assert_includes response.body, 'previewVideo-0'
    assert_not_includes response.body, 'previewVideo-1'
  end

  def test_get_available_states_returns_json_with_country_code
    Rails.cache.clear
    create(:skatepark, country_code: 'US', state: 'CA')
    create(:skatepark, country_code: 'US', state: 'TX')

    get '/available_states', params: { country_code: 'US' }, as: :json

    assert_response :success
    assert_match(/json/, response.content_type)
    json_response = response.parsed_body

    assert_instance_of Array, json_response
    assert_includes json_response.pluck('code'), 'CA'
    assert_includes json_response.pluck('code'), 'TX'
  end

  def test_get_available_states_returns_turbo_stream_with_country_code
    Rails.cache.clear
    create(:skatepark, country_code: 'US', state: 'CA')
    create(:skatepark, country_code: 'US', state: 'TX')

    get '/available_states', params: { country_code: 'US' }, as: :turbo_stream

    assert_response :success
    assert_match(/turbo-stream/, response.content_type)
    assert_includes response.body, 'turbo-stream'
    assert_includes response.body, 'state_select'
  end

  def test_get_available_states_filters_states_by_selected_country
    Rails.cache.clear
    create(:skatepark, country_code: 'US', state: 'CA')
    create(:skatepark, country_code: 'US', state: 'TX')
    create(:skatepark, country_code: 'GR', state: 'I')

    get '/available_states', params: { country_code: 'US' }, as: :json
    json_response = response.parsed_body

    assert_includes json_response.pluck('code'), 'CA'
    assert_includes json_response.pluck('code'), 'TX'
    assert_not_includes json_response.pluck('code'), 'I'
  end

  def test_get_available_states_returns_empty_array_json_without_country_code
    get '/available_states', as: :json

    assert_response :success
    json_response = response.parsed_body

    assert_equal [], json_response
  end

  def test_get_available_states_returns_empty_array_json_with_invalid_country_code
    get '/available_states', params: { country_code: 'ZZ' }, as: :json

    assert_response :success
    assert_equal [], response.parsed_body
  end

  def test_get_available_states_returns_empty_states_turbo_stream_without_country_code
    get '/available_states', as: :turbo_stream

    assert_response :success
    assert_equal [], assigns(:states)
  end

  def test_get_available_states_returns_empty_states_turbo_stream_with_invalid_country_code
    get '/available_states', params: { country_code: 'ZZ' }, as: :turbo_stream

    assert_response :success
    assert_match(/turbo-stream/, response.content_type)
    assert_equal [], assigns(:states)
    assert_includes response.body, 'disabled'
  end

  def test_get_index_returns_success_with_invalid_country_code
    get skateparks_path(country_code: 'ZZ')

    assert_response :success
    assert_equal [], assigns(:states)
  end

  private

  def create_us_skatepark(name:, lat:, lng:, state: 'CA')
    create(
      :skatepark,
      name_en: name,
      name_el: name,
      country_code: 'US',
      state: state,
      lat: lat,
      lng: lng
    )
  end

  def capture_sql_queries(&)
    queries = []
    callback = lambda do |_name, _started, _finished, _unique_id, payload|
      sql = payload[:sql]
      next if payload[:name] == 'SCHEMA' || payload[:cached]
      next if sql.match?(/\A(?:BEGIN|COMMIT|ROLLBACK|SAVEPOINT|RELEASE SAVEPOINT)/)

      queries << sql.squish
    end

    ActiveSupport::Notifications.subscribed(callback, 'sql.active_record', &)

    queries
  end

  def count_matching_queries(queries, pattern)
    queries.count { |query| query.match?(pattern) }
  end
end
