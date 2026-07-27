require 'test_helper'

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  def setup
    @skatepark = create(:skatepark)
  end

  def test_redirects_explicit_default_locale_param_to_clean_url
    get skatepark_path(@skatepark, locale: :en)

    assert_redirected_to skatepark_path(@skatepark)
  end

  def test_preserves_non_locale_query_params_when_redirecting_default_locale
    get skateparks_path(locale: :en, country_code: 'GR', page: 2)

    assert_redirected_to skateparks_path(country_code: 'GR', page: 2)
  end

  def test_does_not_redirect_non_default_locale_param
    get skatepark_path(@skatepark, locale: :el)

    assert_response :success
  end

  def test_does_not_redirect_when_locale_param_is_absent
    get skatepark_path(@skatepark)

    assert_response :success
  end

  def test_does_not_redirect_post_requests_with_default_locale_param
    post session_path(locale: :en), params: { email_address: 'unknown@example.com', password: 'wrong' }

    assert_response :redirect
    assert_equal 302, response.status
  end
end
