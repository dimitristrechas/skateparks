require 'test_helper'

module Admin
  class PopularSkateparksControllerTest < ActionDispatch::IntegrationTest
    include Rails.application.routes.url_helpers

    def setup
      @admin = create(:user, :admin)
      login_as(@admin)
      @first_published_skatepark = create(:skatepark)
      @second_published_skatepark = create(:skatepark)
      @draft_skatepark = create(:skatepark, :draft)
      @first_popular_skatepark = create(:popular_skatepark, skatepark: @first_published_skatepark, position: 1)
      @second_popular_skatepark = create(:popular_skatepark, skatepark: @second_published_skatepark, position: 2)
    end

    def test_get_index_returns_success
      get admin_popular_skateparks_path

      assert_response :success
    end

    def test_get_index_assigns_all_popular_skateparks
      get admin_popular_skateparks_path

      assert_equal [@first_popular_skatepark, @second_popular_skatepark].sort, assigns(:popular_skateparks).sort
    end

    def test_get_index_assigns_available_published_skateparks_not_in_popular_list
      unpopular_skatepark = create(:skatepark)
      get admin_popular_skateparks_path
      available = assigns(:available_skateparks)

      assert_includes available, unpopular_skatepark
      assert_not_includes available, @first_published_skatepark
      assert_not_includes available, @second_published_skatepark
      assert_not_includes available, @draft_skatepark
    end

    def test_post_create_with_valid_params_creates_popular_skatepark
      unpopular_skatepark = create(:skatepark)
      valid_params = {
        popular_skatepark: {
          skatepark_id: unpopular_skatepark.id,
          position: 3,
        },
      }

      assert_difference('PopularSkatepark.count', 1) do
        post admin_popular_skateparks_path, params: valid_params
      end
    end

    def test_post_create_assigns_correct_attributes
      unpopular_skatepark = create(:skatepark)
      valid_params = {
        popular_skatepark: {
          skatepark_id: unpopular_skatepark.id,
          position: 3,
        },
      }

      post admin_popular_skateparks_path, params: valid_params
      popular = PopularSkatepark.last

      assert_equal unpopular_skatepark.id, popular.skatepark_id
      assert_equal 3, popular.position
    end

    def test_post_create_redirects_to_index
      unpopular_skatepark = create(:skatepark)
      valid_params = {
        popular_skatepark: {
          skatepark_id: unpopular_skatepark.id,
          position: 3,
        },
      }

      post admin_popular_skateparks_path, params: valid_params

      assert_redirected_to admin_popular_skateparks_url
    end

    def test_post_create_sets_flash_notice
      unpopular_skatepark = create(:skatepark)
      valid_params = {
        popular_skatepark: {
          skatepark_id: unpopular_skatepark.id,
          position: 3,
        },
      }

      post admin_popular_skateparks_path, params: valid_params

      assert_equal I18n.t('admin.popular_skateparks.added_notice'), flash[:notice]
    end

    def test_post_create_with_duplicate_skatepark_id_does_not_create
      invalid_params = {
        popular_skatepark: {
          skatepark_id: @first_published_skatepark.id,
          position: 4,
        },
      }

      assert_no_difference('PopularSkatepark.count') do
        post admin_popular_skateparks_path, params: invalid_params
      end
    end

    def test_post_create_with_invalid_params_renders_index_template
      invalid_params = {
        popular_skatepark: {
          skatepark_id: @first_published_skatepark.id,
          position: 4,
        },
      }

      post admin_popular_skateparks_path, params: invalid_params

      assert_template :index
    end

    def test_post_create_with_invalid_params_returns_unprocessable_content
      invalid_params = {
        popular_skatepark: {
          skatepark_id: @first_published_skatepark.id,
          position: 4,
        },
      }

      post admin_popular_skateparks_path, params: invalid_params

      assert_response :unprocessable_content
    end

    def test_post_create_with_invalid_params_assigns_popular_skateparks
      invalid_params = {
        popular_skatepark: {
          skatepark_id: @first_published_skatepark.id,
          position: 4,
        },
      }

      post admin_popular_skateparks_path, params: invalid_params

      assert_equal [@first_popular_skatepark, @second_popular_skatepark].sort, assigns(:popular_skateparks).sort
    end

    def test_post_create_with_invalid_params_assigns_available_skateparks
      invalid_params = {
        popular_skatepark: {
          skatepark_id: @first_published_skatepark.id,
          position: 4,
        },
      }

      post admin_popular_skateparks_path, params: invalid_params

      assert_not_nil assigns(:available_skateparks)
    end

    def test_post_create_without_position_does_not_create
      unpopular_skatepark = create(:skatepark)

      assert_no_difference('PopularSkatepark.count') do
        post admin_popular_skateparks_path,
             params: { popular_skatepark: { skatepark_id: unpopular_skatepark.id, position: nil } }
      end
    end

    def test_patch_update_with_valid_params_updates_position
      {
        id: @first_popular_skatepark.id,
        popular_skatepark: { position: 10 },
      }

      patch admin_popular_skatepark_path(@first_popular_skatepark), params: { popular_skatepark: { position: 10 } }
      @first_popular_skatepark.reload

      assert_equal 10, @first_popular_skatepark.position
    end

    def test_patch_update_redirects_to_index
      {
        id: @first_popular_skatepark.id,
        popular_skatepark: { position: 10 },
      }

      patch admin_popular_skatepark_path(@first_popular_skatepark), params: { popular_skatepark: { position: 10 } }

      assert_redirected_to admin_popular_skateparks_url
    end

    def test_patch_update_sets_flash_notice
      {
        id: @first_popular_skatepark.id,
        popular_skatepark: { position: 10 },
      }

      patch admin_popular_skatepark_path(@first_popular_skatepark), params: { popular_skatepark: { position: 10 } }

      assert_equal I18n.t('admin.popular_skateparks.updated_notice'), flash[:notice]
    end

    def test_patch_update_clears_cache
      {
        id: @first_popular_skatepark.id,
        popular_skatepark: { position: 10 },
      }

      Rails.cache.expects(:delete).with(Skatepark.homepage_popular_cache_key)
      patch admin_popular_skatepark_path(@first_popular_skatepark), params: { popular_skatepark: { position: 10 } }
    end

    def test_patch_update_with_invalid_params_does_not_update
      original_position = @first_popular_skatepark.position
      {
        id: @first_popular_skatepark.id,
        popular_skatepark: { position: nil },
      }

      patch admin_popular_skatepark_path(@first_popular_skatepark), params: { popular_skatepark: { position: nil } }
      @first_popular_skatepark.reload

      assert_equal original_position, @first_popular_skatepark.position
    end

    def test_patch_update_with_invalid_params_renders_index_template
      {
        id: @first_popular_skatepark.id,
        popular_skatepark: { position: nil },
      }

      patch admin_popular_skatepark_path(@first_popular_skatepark), params: { popular_skatepark: { position: nil } }

      assert_template :index
    end

    def test_patch_update_with_invalid_params_returns_unprocessable_content
      {
        id: @first_popular_skatepark.id,
        popular_skatepark: { position: nil },
      }

      patch admin_popular_skatepark_path(@first_popular_skatepark), params: { popular_skatepark: { position: nil } }

      assert_response :unprocessable_content
    end

    def test_patch_update_with_invalid_params_assigns_popular_skateparks
      {
        id: @first_popular_skatepark.id,
        popular_skatepark: { position: nil },
      }

      patch admin_popular_skatepark_path(@first_popular_skatepark), params: { popular_skatepark: { position: nil } }

      assert_equal [@first_popular_skatepark, @second_popular_skatepark].sort, assigns(:popular_skateparks).sort
    end

    def test_patch_update_with_invalid_params_assigns_available_skateparks
      {
        id: @first_popular_skatepark.id,
        popular_skatepark: { position: nil },
      }

      patch admin_popular_skatepark_path(@first_popular_skatepark), params: { popular_skatepark: { position: nil } }

      assert_not_nil assigns(:available_skateparks)
    end

    def test_patch_update_raises_error_when_not_found
      patch admin_popular_skatepark_path(99_999), params: { popular_skatepark: { position: 5 } }

      assert_response :not_found
    end

    def test_delete_destroy_destroys_popular_skatepark
      assert_difference('PopularSkatepark.count', -1) do
        delete admin_popular_skatepark_path(@first_popular_skatepark)
      end
    end

    def test_delete_destroy_redirects_to_index
      delete admin_popular_skatepark_path(@first_popular_skatepark)

      assert_redirected_to admin_popular_skateparks_url
    end

    def test_delete_destroy_sets_flash_notice
      delete admin_popular_skatepark_path(@first_popular_skatepark)

      assert_equal I18n.t('admin.popular_skateparks.removed_notice'), flash[:notice]
    end

    def test_delete_destroy_clears_cache
      Rails.cache.expects(:delete).with(Skatepark.homepage_popular_cache_key)
      delete admin_popular_skatepark_path(@first_popular_skatepark)
    end

    def test_delete_destroy_does_not_destroy_associated_skatepark
      skatepark = @first_popular_skatepark.skatepark

      assert_no_difference('Skatepark.count') do
        delete admin_popular_skatepark_path(@first_popular_skatepark)
      end

      assert Skatepark.exists?(skatepark.id)
    end

    def test_delete_destroy_raises_error_when_not_found
      delete admin_popular_skatepark_path(999_999)

      assert_response :not_found
    end

    def test_non_admin_blocked_from_popular_skateparks
      user = create(:user, role: :user)
      login_as(user)
      get admin_popular_skateparks_path

      assert_redirected_to root_path
      assert_match(/not authorized/, flash[:alert])
    end
  end
end
