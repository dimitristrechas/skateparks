module Admin
  class VideoSuggestionsController < BaseController
    before_action :set_video_suggestion, only: %i[activate reject]

    def index
      @video_suggestions = SkateparkVideo.pending_review
                                         .includes(skatepark: :string_translations,
                                                   proposed_skatepark: :string_translations)
                                         .order(created_at: :desc)
      @skateparks = Skatepark.published.i18n.includes(:string_translations).order(:name)
    end

    def activate
      target_skatepark = Skatepark.published.find(activate_params)

      if activate_video_on!(target_skatepark)
        redirect_to admin_video_suggestions_path, notice: activation_notice_for(target_skatepark)
      else
        render_activation_failure
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_video_suggestions_path, alert: t('admin.video_suggestions.invalid_skatepark')
    rescue ActiveRecord::RecordNotUnique
      @video_suggestion.errors.add(:youtube_url, duplicate_youtube_url_error_key(target_skatepark))
      render_activation_failure
    end

    def reject
      if @video_suggestion.update(status: :rejected)
        redirect_to admin_video_suggestions_path, notice: t('admin.video_suggestions.rejected_notice')
      else
        flash.now[:alert] = @video_suggestion.errors.full_messages.to_sentence
        index
        render :index, status: :unprocessable_content
      end
    end

    private

    def set_video_suggestion
      @video_suggestion = SkateparkVideo.pending_review.find(params[:id])
    end

    def activate_params
      params.expect(:skatepark_id)
    end

    def activate_video_on!(target_skatepark)
      success = false

      target_skatepark.with_lock do
        ActiveRecord::Base.transaction do
          @video_suggestion.skatepark = target_skatepark
          @video_suggestion.status = :active
          @video_suggestion.position = SkateparkVideo.next_active_position_for(target_skatepark)
          @video_suggestion.allow_negative_position = false

          success = @video_suggestion.save
          raise ActiveRecord::Rollback unless success
        end
      end

      success
    end

    def activation_notice_for(target_skatepark)
      if target_skatepark.id == @video_suggestion.proposed_skatepark_id
        t('admin.video_suggestions.activated_notice')
      else
        t('admin.video_suggestions.activated_reassigned_notice', skatepark: target_skatepark.name)
      end
    end

    def render_activation_failure
      flash.now[:alert] = @video_suggestion.errors.full_messages.to_sentence
      index
      render :index, status: :unprocessable_content
    end

    def duplicate_youtube_url_error_key(target_skatepark)
      existing = target_skatepark.skatepark_videos.find_by(
        youtube_video_id: @video_suggestion.youtube_video_id,
        status: %i[pending active]
      )

      return :already_submitted if existing.blank?

      existing.active? ? :already_published : :already_pending
    end
  end
end
