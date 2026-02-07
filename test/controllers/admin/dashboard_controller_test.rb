require 'test_helper'

module Admin
  class DashboardControllerTest < ActionDispatch::IntegrationTest
    def setup
      # Mock authentication
      ApplicationController.any_instance.stubs(:http_basic_authenticate_or_request_with).returns(true)
    end

    def test_get_index_returns_success
      get admin_root_path
      assert_response :success
    end

    def test_get_index_renders_index_template
      get admin_root_path
      assert_template :index
    end
  end
end
