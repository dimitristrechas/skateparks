require 'test_helper'

module Admin
  class SkateparksControllerTest < ActionDispatch::IntegrationTest
    include ActionView::Helpers::SanitizeHelper
    include Rails.application.routes.url_helpers

    def setup
      @admin = create(:user, :admin)
      login_as(@admin)
      @skatepark = create(:skatepark)
      @valid_attributes = attributes_for(:skatepark)
      @invalid_attributes = {
        name: nil,
        lat: nil,
        lng: nil,
        description: nil,
        cover_image: nil,
        images: [],
        status: nil,
      }
    end

    def test_get_index_returns_success_and_assigns_skateparks
      get admin_skateparks_path
      assert_response :success
      assert_includes assigns(:skateparks), @skatepark
    end

    def test_get_index_returns_skateparks_in_alphabetical_order
      create(:skatepark, name_en: 'Zebra Park', name_el: 'Zebra Park')
      create(:skatepark, name_en: 'Alpha Park', name_el: 'Alpha Park')
      create(:skatepark, name_en: 'Middle Park', name_el: 'Middle Park')

      get admin_skateparks_path
      names = assigns(:skateparks).map(&:name)
      assert_equal names.sort, names
    end

    def test_get_show_returns_success_and_assigns_skatepark
      get admin_skatepark_path(@skatepark)
      assert_response :success
      assert_equal @skatepark, assigns(:skatepark)
    end

    def test_get_new_returns_success_and_assigns_new_skatepark
      get new_admin_skatepark_path
      assert_response :success
      assert assigns(:skatepark).new_record?
    end

    def test_get_edit_returns_success_and_assigns_skatepark
      get edit_admin_skatepark_path(@skatepark)
      assert_response :success
      assert_equal @skatepark, assigns(:skatepark)
    end

    def test_post_create_with_valid_params_creates_skatepark
      assert_difference('Skatepark.count', 1) do
        post admin_skateparks_path, params: { skatepark: @valid_attributes }
      end
    end

    def test_post_create_with_valid_params_redirects_to_skateparks_list
      post admin_skateparks_path, params: { skatepark: @valid_attributes }
      assert_redirected_to admin_skateparks_url
    end

    def test_post_create_with_invalid_params_does_not_create_skatepark
      assert_no_difference('Skatepark.count') do
        post admin_skateparks_path, params: { skatepark: @invalid_attributes }
      end
    end

    def test_post_create_with_invalid_params_renders_new_template
      post admin_skateparks_path, params: { skatepark: @invalid_attributes }
      assert_template 'new'
    end

    def test_patch_update_with_valid_params_updates_skatepark
      new_attributes = {
        name_el: 'Updated Skatepark',
        lat: 23.456,
        lng: 78.901,
        description_el: '<strong>An updated description</strong>',
      }

      patch admin_skatepark_path(@skatepark), params: { skatepark: new_attributes }
      @skatepark.reload
      assert_equal 'Updated Skatepark', @skatepark.name_el
      assert_equal 23.456, @skatepark.lat
      assert_equal 78.901, @skatepark.lng
      assert_equal 'An updated description', @skatepark.description_el.to_plain_text
    end

    def test_patch_update_with_valid_params_redirects_to_skateparks_list
      new_attributes = {
        name_el: 'Updated Skatepark',
        lat: 23.456,
        lng: 78.901,
        description_el: '<strong>An updated description</strong>',
      }

      patch admin_skatepark_path(@skatepark), params: { skatepark: new_attributes }
      assert_redirected_to admin_skateparks_url
    end

    def test_patch_update_with_invalid_params_renders_edit_template
      patch admin_skatepark_path(@skatepark), params: { skatepark: @invalid_attributes }
      assert_template 'edit'
    end

    def test_delete_destroy_destroys_skatepark
      assert_difference('Skatepark.count', -1) do
        delete admin_skatepark_path(@skatepark)
      end
    end

    def test_delete_destroy_redirects_to_skateparks_list
      delete admin_skatepark_path(@skatepark)
      assert_redirected_to admin_skateparks_url
    end

    def test_non_admin_blocked_from_skateparks
      user = create(:user, role: :user)
      login_as(user)
      get admin_skateparks_path
      assert_redirected_to root_path
      assert_match(/not authorized/, flash[:alert])
    end
  end
end
