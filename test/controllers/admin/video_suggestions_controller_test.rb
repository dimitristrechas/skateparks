require 'test_helper'

module Admin
  class VideoSuggestionsControllerTest < ActionDispatch::IntegrationTest
    include Rails.application.routes.url_helpers

    def setup
      Rails.cache.clear
      @admin = create(:user, :admin)
      login_as(@admin)
      @proposed_skatepark = create(:skatepark, name_en: 'Proposed Park', name_el: 'Proposed Park')
      @target_skatepark = create(:skatepark, name_en: 'Target Park', name_el: 'Target Park')
      @video_suggestion = create(
        :skatepark_video,
        :pending,
        skatepark: @proposed_skatepark,
        proposed_skatepark: @proposed_skatepark,
        youtube_url: 'https://youtu.be/dQw4w9WgXcQ'
      )
    end

    def test_get_index_returns_success
      get admin_video_suggestions_path

      assert_response :success
      assert_includes assigns(:video_suggestions), @video_suggestion
    end

    def test_get_index_requires_admin
      delete session_path

      get admin_video_suggestions_path

      assert_redirected_to new_session_path
    end

    def test_post_activate_sets_video_active_and_assigns_position
      post activate_admin_video_suggestion_path(@video_suggestion),
           params: { skatepark_id: @proposed_skatepark.id }

      @video_suggestion.reload

      assert_redirected_to admin_video_suggestions_path
      assert_predicate @video_suggestion, :active?
      assert_equal 1, @video_suggestion.position
      assert_equal 1, @proposed_skatepark.reload.skatepark_videos_count
    end

    def test_post_activate_can_reassign_video_to_another_skatepark
      post activate_admin_video_suggestion_path(@video_suggestion),
           params: { skatepark_id: @target_skatepark.id }

      @video_suggestion.reload

      assert_predicate @video_suggestion, :active?
      assert_equal @target_skatepark.id, @video_suggestion.skatepark_id
      assert_equal @proposed_skatepark.id, @video_suggestion.proposed_skatepark_id
      assert_equal 1, @target_skatepark.reload.skatepark_videos_count
      assert_equal 0, @proposed_skatepark.reload.skatepark_videos_count
    end

    def test_post_activate_fails_when_target_skatepark_already_has_url
      create(:skatepark_video, skatepark: @target_skatepark, youtube_url: 'https://youtu.be/dQw4w9WgXcQ')

      assert_no_difference(-> { @target_skatepark.reload.skatepark_videos_count }) do
        post activate_admin_video_suggestion_path(@video_suggestion),
             params: { skatepark_id: @target_skatepark.id }
      end

      assert_response :unprocessable_content
      assert_predicate @video_suggestion.reload, :pending?
    end

    def test_post_activate_handles_concurrent_duplicate_submission
      create(:skatepark_video, skatepark: @target_skatepark, youtube_url: 'https://youtu.be/dQw4w9WgXcQ')

      SkateparkVideo.any_instance.stubs(:save).raises(ActiveRecord::RecordNotUnique.new('duplicate key'))

      post activate_admin_video_suggestion_path(@video_suggestion),
           params: { skatepark_id: @target_skatepark.id }

      assert_response :unprocessable_content
      assert_predicate @video_suggestion.reload, :pending?
      assert_includes response.body,
                      I18n.t('activerecord.errors.models.skatepark_video.attributes.youtube_url.already_published')
    end

    def test_post_reject_keeps_record_on_original_skatepark
      post reject_admin_video_suggestion_path(@video_suggestion)

      @video_suggestion.reload

      assert_redirected_to admin_video_suggestions_path
      assert_predicate @video_suggestion, :rejected?
      assert_equal @proposed_skatepark.id, @video_suggestion.skatepark_id
    end
  end
end
