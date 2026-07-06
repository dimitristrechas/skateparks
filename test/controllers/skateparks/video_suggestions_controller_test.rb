require 'test_helper'

module Skateparks
  class VideoSuggestionsControllerTest < ActionDispatch::IntegrationTest
    include Rails.application.routes.url_helpers

    def setup
      Rails.cache.clear
      @skatepark = create(:skatepark)
    end

    def test_create_submits_pending_video_suggestion
      assert_difference(-> { SkateparkVideo.pending_review.count }, 1) do
        post skatepark_video_suggestion_path(@skatepark),
             params: { video_suggestion: { youtube_url: 'https://youtu.be/dQw4w9WgXcQ' } },
             as: :turbo_stream
      end

      video_suggestion = SkateparkVideo.pending_review.last

      assert_equal 'pending', video_suggestion.status
      assert_equal [@skatepark.id, @skatepark.id],
                   [video_suggestion.skatepark_id, video_suggestion.proposed_skatepark_id]
      assert_equal 'dQw4w9WgXcQ', video_suggestion.youtube_video_id
      assert_response :success
    end

    def test_create_rejects_invalid_youtube_url
      assert_no_difference(-> { SkateparkVideo.count }) do
        post skatepark_video_suggestion_path(@skatepark),
             params: { video_suggestion: { youtube_url: 'https://example.com/not-youtube' } },
             as: :turbo_stream
      end

      assert_response :unprocessable_content
    end

    def test_create_rejects_duplicate_active_url_for_skatepark
      create(:skatepark_video, skatepark: @skatepark, youtube_url: 'https://youtu.be/dQw4w9WgXcQ')

      assert_no_difference(-> { SkateparkVideo.pending_review.count }) do
        post skatepark_video_suggestion_path(@skatepark),
             params: { video_suggestion: { youtube_url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ' } },
             as: :turbo_stream
      end

      assert_response :unprocessable_content
      assert_includes response.body,
                      I18n.t('activerecord.errors.models.skatepark_video.attributes.youtube_url.already_published')
    end

    def test_create_rejects_duplicate_pending_url_for_skatepark
      create(:skatepark_video, :pending, skatepark: @skatepark, youtube_url: 'https://youtu.be/dQw4w9WgXcQ')

      assert_no_difference(-> { SkateparkVideo.count }) do
        post skatepark_video_suggestion_path(@skatepark),
             params: { video_suggestion: { youtube_url: 'https://youtu.be/dQw4w9WgXcQ' } },
             as: :turbo_stream
      end

      assert_response :unprocessable_content
      assert_includes response.body,
                      I18n.t('activerecord.errors.models.skatepark_video.attributes.youtube_url.already_pending')
    end

    def test_create_allows_resubmission_after_rejection
      create(:skatepark_video, :rejected, skatepark: @skatepark, youtube_url: 'https://youtu.be/dQw4w9WgXcQ')

      assert_difference(-> { SkateparkVideo.pending_review.count }, 1) do
        post skatepark_video_suggestion_path(@skatepark),
             params: { video_suggestion: { youtube_url: 'https://youtu.be/dQw4w9WgXcQ' } },
             as: :turbo_stream
      end

      assert_response :success
      assert_equal 0, SkateparkVideo.rejected.where(skatepark: @skatepark, youtube_video_id: 'dQw4w9WgXcQ').count
    end

    def test_create_handles_concurrent_duplicate_submission
      create(:skatepark_video, skatepark: @skatepark, youtube_url: 'https://youtu.be/dQw4w9WgXcQ')

      SkateparkVideo.any_instance.stubs(:save).raises(ActiveRecord::RecordNotUnique.new('duplicate key'))

      post skatepark_video_suggestion_path(@skatepark),
           params: { video_suggestion: { youtube_url: 'https://youtu.be/dQw4w9WgXcQ' } },
           as: :turbo_stream

      assert_response :unprocessable_content
      assert_includes response.body,
                      I18n.t('activerecord.errors.models.skatepark_video.attributes.youtube_url.already_published')
    end

    def test_create_returns_not_found_for_unpublished_skatepark
      draft_skatepark = create(:skatepark, :draft)

      post skatepark_video_suggestion_path(draft_skatepark),
           params: { video_suggestion: { youtube_url: 'https://youtu.be/dQw4w9WgXcQ' } }

      assert_response :not_found
    end

    def test_create_ignores_honeypot_and_returns_success_without_creating_record
      assert_no_difference(-> { SkateparkVideo.count }) do
        post skatepark_video_suggestion_path(@skatepark),
             params: { video_suggestion: { youtube_url: 'https://youtu.be/dQw4w9WgXcQ', website: 'spam' } },
             as: :turbo_stream
      end

      assert_response :success
    end

    def test_create_rejects_oversized_youtube_url
      assert_no_difference(-> { SkateparkVideo.count }) do
        post skatepark_video_suggestion_path(@skatepark),
             params: { video_suggestion: { youtube_url: "https://youtu.be/#{'a' * 250}" } },
             as: :turbo_stream
      end

      assert_response :unprocessable_content
    end

    def test_create_rate_limits_submissions_per_ip
      5.times do |index|
        post skatepark_video_suggestion_path(@skatepark),
             params: { video_suggestion: { youtube_url: "https://youtu.be/#{format('%011d', index)}" } },
             as: :turbo_stream

        assert_response :success
      end

      post skatepark_video_suggestion_path(@skatepark),
           params: { video_suggestion: { youtube_url: 'https://youtu.be/zzzzzzzzzzz' } },
           as: :turbo_stream

      assert_response :too_many_requests
    end

    def test_create_rate_limit_redirects_to_homepage_when_skatepark_missing
      5.times do |index|
        post skatepark_video_suggestion_path(@skatepark),
             params: { video_suggestion: { youtube_url: "https://youtu.be/#{format('%011d', index)}" } },
             as: :turbo_stream

        assert_response :success
      end

      draft_skatepark = create(:skatepark, :draft)

      post skatepark_video_suggestion_path(draft_skatepark),
           params: { video_suggestion: { youtube_url: 'https://youtu.be/zzzzzzzzzzz' } },
           as: :html

      assert_redirected_to root_path
      assert_equal I18n.t('skateparks.video_suggestion.rate_limit_exceeded'), flash[:alert]
    end
  end
end
