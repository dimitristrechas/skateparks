require 'test_helper'

module Admin
  class SkateparksControllerTest < ActionDispatch::IntegrationTest
    include ActionView::Helpers::SanitizeHelper
    include Rails.application.routes.url_helpers

    def setup
      @admin = create(:user, :admin)
      login_as(@admin)
      @skatepark = create(:skatepark)
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
      assert_predicate assigns(:skatepark), :new_record?
    end

    def test_get_edit_returns_success_and_assigns_skatepark
      get edit_admin_skatepark_path(@skatepark)

      assert_response :success
      assert_equal @skatepark, assigns(:skatepark)
    end

    def test_post_create_with_valid_params_creates_skatepark
      assert_difference('Skatepark.count', 1) do
        assert_difference('SkateparkImage.count', 2) do
          post admin_skateparks_path, params: { skatepark: valid_skatepark_params }
        end
      end

      skatepark = Skatepark.order(:id).last

      assert_equal [1, 2], skatepark.skatepark_images.pluck(:position)
    end

    def test_post_create_respects_new_image_positions
      post admin_skateparks_path, params: {
        skatepark: valid_skatepark_params.merge(new_image_positions: %w[2 1]),
      }

      skatepark = Skatepark.order(:id).last
      ordered_filenames = skatepark.skatepark_images.map { |image| image.image.filename.to_s }

      assert_equal %w[sample_image3.jpg sample_image1.jpg], ordered_filenames
    end

    def test_post_create_with_valid_params_redirects_to_skateparks_list
      post admin_skateparks_path, params: { skatepark: valid_skatepark_params }

      assert_redirected_to admin_skateparks_url
    end

    def test_post_create_with_invalid_params_does_not_create_skatepark
      assert_no_difference('Skatepark.count') do
        post admin_skateparks_path, params: { skatepark: invalid_skatepark_params }
      end
    end

    def test_post_create_with_invalid_params_renders_new_template
      post admin_skateparks_path, params: { skatepark: invalid_skatepark_params }

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
      assert_in_delta(23.456, @skatepark.lat)
      assert_in_delta(78.901, @skatepark.lng)
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
      patch admin_skatepark_path(@skatepark), params: { skatepark: invalid_skatepark_params }

      assert_template 'edit'
    end

    def test_patch_update_reorders_skatepark_images
      first_image, second_image = @skatepark.skatepark_images.to_a

      patch admin_skatepark_path(@skatepark), params: {
        skatepark: {
          skatepark_images_attributes: {
            '0' => { id: first_image.id, position: 2 },
            '1' => { id: second_image.id, position: 1 },
          },
        },
      }

      assert_redirected_to admin_skateparks_url
      assert_equal [second_image.id, first_image.id], @skatepark.reload.skatepark_images.pluck(:id)
    end

    def test_patch_update_appends_new_images_after_existing_images
      patch admin_skatepark_path(@skatepark), params: {
        skatepark: {
          new_images: [
            uploaded_image('sample_image1.jpg', 'new_sample_image1.jpg'),
            uploaded_image('sample_image3.jpg', 'new_sample_image3.jpg'),
          ],
        },
      }

      assert_redirected_to admin_skateparks_url
      assert_equal [1, 2, 3, 4], @skatepark.reload.skatepark_images.pluck(:position)
    end

    def test_patch_update_can_insert_new_images_between_existing_images
      first_image, second_image = @skatepark.skatepark_images.to_a

      patch admin_skatepark_path(@skatepark), params: mixed_reorder_params(first_image, second_image)

      ordered_images = @skatepark.reload.skatepark_images.to_a

      assert_mixed_reorder_result(ordered_images, first_image.id, second_image.id)
    end

    def test_patch_update_destroys_image_marked_with_destroy
      first_image, second_image = @skatepark.skatepark_images.to_a

      patch admin_skatepark_path(@skatepark), params: {
        skatepark: {
          skatepark_images_attributes: {
            '0' => { id: first_image.id, position: 1 },
            '1' => { id: second_image.id, position: 2, _destroy: '1' },
          },
          new_images: [
            uploaded_image('sample_image3.jpg', 'replacement_image.jpg'),
          ],
          new_image_positions: ['2'],
        },
      }

      assert_redirected_to admin_skateparks_url

      remaining_ids = @skatepark.reload.skatepark_images.pluck(:id)

      assert_includes remaining_ids, first_image.id
      assert_not_includes remaining_ids, second_image.id
    end

    def test_patch_update_rejects_duplicate_new_image_filename
      assert_no_difference('SkateparkImage.count') do
        patch admin_skatepark_path(@skatepark), params: {
          skatepark: {
            new_images: [
              fixture_file_upload('sample_image1.jpg', 'image/jpeg'),
            ],
            new_image_positions: ['3'],
          },
        }
      end

      assert_template 'edit'
      assert_includes assigns(:skatepark).errors[:images], 'sample_image1.jpg has already been uploaded'
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

    def test_get_states_returns_json_for_valid_country_code
      get '/admin/states/US', as: :json

      assert_response :success
      assert_match(/json/, response.content_type)
      assert_includes response.parsed_body.keys, 'CA'
    end

    def test_get_states_returns_empty_json_for_invalid_country_code
      get '/admin/states/ZZ', as: :json

      assert_response :success
      assert_equal({}, response.parsed_body)
    end

    private

    def valid_skatepark_params
      {
        name_el: 'Valid Skatepark',
        name_en: 'Valid Skatepark',
        lat: 23.456,
        lng: 78.901,
        description_el: 'Περιγραφή skatepark',
        description_en: 'Skatepark description',
        cover_image: fixture_file_upload('sample_image2.jpg', 'image/jpeg'),
        new_images: [
          fixture_file_upload('sample_image1.jpg', 'image/jpeg'),
          fixture_file_upload('sample_image3.jpg', 'image/jpeg'),
        ],
        new_image_positions: %w[1 2],
        google_id: 'test-google-id',
        status: 'published',
        country_code: 'GR',
        state: 'I',
      }
    end

    def invalid_skatepark_params
      {
        name_el: nil,
        name_en: nil,
        lat: nil,
        lng: nil,
        description_el: nil,
        description_en: nil,
        cover_image: nil,
        new_images: [],
        status: nil,
        country_code: nil,
        state: nil,
      }
    end

    def mixed_reorder_params(first_image, second_image)
      {
        skatepark: {
          skatepark_images_attributes: {
            '0' => { id: first_image.id, position: 1 },
            '1' => { id: second_image.id, position: 3 },
          },
          new_images: [
            uploaded_image('sample_image1.jpg', 'inserted_sample_image1.jpg'),
          ],
          new_image_positions: ['2'],
        },
      }
    end

    def assert_mixed_reorder_result(ordered_images, first_image_id, second_image_id)
      assert_redirected_to admin_skateparks_url
      assert_equal [1, 2, 3], ordered_images.map(&:position)
      assert_equal first_image_id, ordered_images.first.id
      assert_equal 'inserted_sample_image1.jpg', ordered_images.second.image.filename.to_s
      assert_equal second_image_id, ordered_images.third.id
    end

    def uploaded_image(image_fixture, original_filename)
      Rack::Test::UploadedFile.new(
        Rails.root.join("test/fixtures/files/#{image_fixture}"),
        'image/jpeg',
        true,
        original_filename: original_filename
      )
    end
  end
end
