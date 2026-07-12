# frozen_string_literal: true

require 'test_helper'

module Admin
  class SiteAnnouncementsControllerTest < ActionDispatch::IntegrationTest
    include Rails.application.routes.url_helpers

    def setup
      @admin = create(:user, :admin)
      login_as(@admin)
      @site_announcement = create(:site_announcement, position: 1)
    end

    def test_get_index_returns_success
      get admin_site_announcements_path

      assert_response :success
    end

    def test_get_index_assigns_site_announcements
      get admin_site_announcements_path

      assert_includes assigns(:site_announcements), @site_announcement
    end

    def test_get_new_returns_success
      get new_admin_site_announcement_path

      assert_response :success
    end

    def test_post_create_with_valid_params_creates_site_announcement
      params = {
        site_announcement: {
          message_en: 'New announcement',
          message_el: 'Νέα ανακοίνωση',
          position: 2,
          published: true,
        },
      }

      assert_difference('SiteAnnouncement.count', 1) do
        post admin_site_announcements_path, params: params
      end

      assert_redirected_to admin_site_announcements_url
    end

    def test_post_create_assigns_next_available_position_ignoring_stale_form_value
      create(:site_announcement, position: 5)

      post admin_site_announcements_path, params: {
        site_announcement: {
          message_en: 'Queued announcement',
          message_el: 'Σειρά ανακοίνωση',
          position: 2,
          published: true,
        },
      }

      assert_redirected_to admin_site_announcements_url
      assert_equal 6, SiteAnnouncement.order(:id).last.position
    end

    def test_post_create_with_invalid_params_renders_new
      params = {
        site_announcement: {
          message_en: '',
          message_el: '',
          position: 0,
        },
      }

      assert_no_difference('SiteAnnouncement.count') do
        post admin_site_announcements_path, params: params
      end

      assert_response :unprocessable_content
    end

    def test_get_edit_returns_success
      get edit_admin_site_announcement_path(@site_announcement)

      assert_response :success
    end

    def test_patch_update_with_valid_params_updates_site_announcement
      patch admin_site_announcement_path(@site_announcement), params: {
        site_announcement: {
          message_en: 'Updated announcement',
        },
      }

      assert_redirected_to admin_site_announcements_url
      assert_equal 'Updated announcement', @site_announcement.reload.message_en
    end

    def test_patch_update_with_invalid_params_renders_edit
      patch admin_site_announcement_path(@site_announcement), params: {
        site_announcement: {
          message_en: '',
        },
      }

      assert_response :unprocessable_content
    end

    def test_delete_destroy_removes_site_announcement
      assert_difference('SiteAnnouncement.count', -1) do
        delete admin_site_announcement_path(@site_announcement)
      end

      assert_redirected_to admin_site_announcements_url
    end

    def test_non_admin_blocked_from_site_announcements
      login_as(create(:user))

      get admin_site_announcements_path

      assert_redirected_to root_path
    end

    def test_non_admin_blocked_from_creating_site_announcement
      login_as(create(:user))

      assert_no_difference('SiteAnnouncement.count') do
        post admin_site_announcements_path, params: {
          site_announcement: {
            message_en: 'Blocked',
            message_el: 'Αποκλεισμένο',
            position: 2,
          },
        }
      end

      assert_redirected_to root_path
    end

    def test_non_admin_blocked_from_updating_site_announcement
      login_as(create(:user))

      patch admin_site_announcement_path(@site_announcement), params: {
        site_announcement: { message_en: 'Blocked update' },
      }

      assert_redirected_to root_path
      assert_not_equal 'Blocked update', @site_announcement.reload.message_en
    end

    def test_non_admin_blocked_from_destroying_site_announcement
      login_as(create(:user))

      assert_no_difference('SiteAnnouncement.count') do
        delete admin_site_announcement_path(@site_announcement)
      end

      assert_redirected_to root_path
    end
  end
end
