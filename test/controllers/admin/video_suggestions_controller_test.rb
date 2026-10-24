require 'test_helper'

module Admin
  class VideoSuggestionsControllerTest < ActionDispatch::IntegrationTest
    include Rails.application.routes.url_helpers

    def setup
      Rails.cache.clear
      @admin = create(:user, :admin)
      login_as(@admin)
      @proposed_skatepark = create(:skatepark, name_en: 'Proposed Park', name_el: 'Πάρκο Πρότασης')
      @target_skatepark = create(:skatepark, name_en: 'Target Park', name_el: 'Πάρκο Στόχος')
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
      assert_nil assigns(:skateparks)
    end

    def test_get_index_renders_single_shared_reassign_modal_instead_of_per_row_selects
      get admin_video_suggestions_path

      assert_response :success
      assert_select 'table select[name="skatepark_id"]', count: 0
      assert_select 'dialog#reassign-skatepark-dialog', count: 1
      assert_select 'dialog#reassign-skatepark-dialog input[role="combobox"]', count: 1
      assert_select 'tr input[type="hidden"][name="skatepark_id"][value=?]', @proposed_skatepark.id.to_s
    end

    def test_get_index_avoids_n_plus_one_queries_across_pending_rows
      create_list(:skatepark, 3).each_with_index do |park, index|
        create(
          :skatepark_video,
          :pending,
          skatepark: park,
          proposed_skatepark: park,
          youtube_url: "https://youtu.be/0000000000#{index + 1}"
        )
      end

      queries = capture_sql_queries do
        get admin_video_suggestions_path
      end

      assert_response :success
      assert_operator count_matching_queries(queries, /FROM "mobility_string_translations"/), :<=, 1
      assert_equal 0, count_matching_queries(queries, /FROM "skateparks" INNER JOIN "mobility_string_translations"/)
    end

    def test_get_index_paginates_pending_suggestions_and_shows_total_pending_count
      Kaminari.config.stubs(:default_per_page).returns(1)
      create(
        :skatepark_video,
        :pending,
        skatepark: @target_skatepark,
        proposed_skatepark: @target_skatepark,
        youtube_url: 'https://youtu.be/9bZkp7q19f0'
      )

      get admin_video_suggestions_path

      assert_response :success
      assert_equal 1, assigns(:video_suggestions).size
      assert_includes response.body, I18n.t('admin.video_suggestions.pending_count', count: 2)
      assert_select "nav[aria-label='#{I18n.t('views.pagination.aria_label')}']"
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

    def test_post_activate_defaults_to_assigned_skatepark_when_param_omitted
      post activate_admin_video_suggestion_path(@video_suggestion)

      @video_suggestion.reload

      assert_redirected_to admin_video_suggestions_path
      assert_predicate @video_suggestion, :active?
      assert_equal @proposed_skatepark.id, @video_suggestion.skatepark_id
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

    def test_post_activate_redirects_when_skatepark_missing
      post activate_admin_video_suggestion_path(@video_suggestion),
           params: { skatepark_id: 0 }

      assert_redirected_to admin_video_suggestions_path
      assert_equal I18n.t('admin.video_suggestions.invalid_skatepark'), flash[:alert]
    end

    def test_post_reject_keeps_record_on_original_skatepark
      post reject_admin_video_suggestion_path(@video_suggestion)

      @video_suggestion.reload

      assert_redirected_to admin_video_suggestions_path
      assert_predicate @video_suggestion, :rejected?
      assert_equal @proposed_skatepark.id, @video_suggestion.skatepark_id
    end

    private

    def capture_sql_queries(&)
      queries = []
      callback = lambda do |_name, _started, _finished, _unique_id, payload|
        sql = payload[:sql]
        next if payload[:name] == 'SCHEMA' || payload[:cached]
        next if sql.match?(/\A(?:BEGIN|COMMIT|ROLLBACK|SAVEPOINT|RELEASE SAVEPOINT)/)

        queries << sql.squish
      end

      ActiveSupport::Notifications.subscribed(callback, 'sql.active_record', &)

      queries
    end

    def count_matching_queries(queries, pattern)
      queries.count { |query| query.match?(pattern) }
    end
  end
end
