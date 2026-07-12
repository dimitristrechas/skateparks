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

    def test_index_renders_counter_bubbles_with_counts
      create(:skatepark_video, :pending)
      create(:site_announcement, published: true)

      get admin_root_path

      assert_response :success
      assert_select 'span[aria-label="1 pending video suggestion"]', text: '1'
      assert_select 'span[aria-label="1 visible site announcement"]', text: '1'
    end

    def test_index_renders_zero_counter_bubbles_when_empty
      get admin_root_path

      assert_response :success
      assert_includes response.body, 'aria-label="0 pending video suggestions"'
      assert_includes response.body, 'aria-label="0 visible site announcements"'
      assert_select 'span[aria-label="0 pending video suggestions"]', text: '0'
      assert_select 'span[aria-label="0 visible site announcements"]', text: '0'
    end
  end
end
