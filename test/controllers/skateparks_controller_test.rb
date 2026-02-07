require 'test_helper'

class SkateparksControllerTest < ActionDispatch::IntegrationTest
  include ActionView::Helpers::SanitizeHelper
  include Rails.application.routes.url_helpers

  def setup
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

  def test_get_show_sets_meta_tags
    get skatepark_path(@skatepark)
    assert_equal "#{@skatepark.name} | Skateparks.gr", assigns(:title)
    assert_equal @skatepark.description.to_plain_text, assigns(:meta_description)
    assert_equal url_for(@skatepark.cover_image), assigns(:meta_image)
  end

  def test_get_show_raises_error_if_skatepark_not_found
    get skatepark_path('nonexistent-id')
    assert_response :not_found
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

  def test_get_available_states_returns_empty_states_turbo_stream_without_country_code
    get '/available_states', as: :turbo_stream
    assert_response :success
    assert_equal [], assigns(:states)
  end
end
