require 'test_helper'

class HealthcheckControllerTest < ActionDispatch::IntegrationTest
  test 'get healthcheck returns success' do
    get rails_health_check_path

    assert_response :success
  end
end
