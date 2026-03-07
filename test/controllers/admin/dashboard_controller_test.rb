require 'test_helper'

module Admin
  class DashboardControllerTest < ActionDispatch::IntegrationTest
    def setup
      @admin = create(:user, :admin)
      login_as(@admin)
    end

    def test_get_index_returns_success
      get admin_root_path

      assert_response :success
    end

    def test_get_index_renders_index_template
      get admin_root_path

      assert_template :index
    end

    def test_non_admin_blocked_from_dashboard
      user = create(:user, role: :user)
      login_as(user)
      get admin_root_path

      assert_redirected_to root_path
      assert_match(/not authorized/, flash[:alert])
    end
  end
end
