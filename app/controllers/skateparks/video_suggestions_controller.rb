module Skateparks
  class VideoSuggestionsController < ApplicationController
    rate_limit to: 5, within: 15.minutes, only: :create, name: 'per-ip', with: lambda {
      respond_to_rate_limit
    }
    rate_limit to: 60, within: 1.hour, only: :create, name: 'per-skatepark', by: lambda {
      params[:skatepark_id]
    }, with: lambda {
      respond_to_rate_limit
    }

    before_action :set_skatepark

    def create
      return respond_with_success if honeypot_triggered?

      @video_suggestion = @skatepark.skatepark_videos.build(video_suggestion_params)
      @video_suggestion.status = :pending
      @video_suggestion.position = 0
      @video_suggestion.proposed_skatepark = @skatepark

      if @video_suggestion.save
        respond_with_success
      else
        respond_with_errors
      end
    rescue ActiveRecord::RecordNotUnique
      @video_suggestion.errors.add(:youtube_url, duplicate_youtube_url_error_key)
      respond_with_errors
    end

    private

    def set_skatepark
      @skatepark = Skatepark.published.find(params.expect(:skatepark_id))
    end

    def video_suggestion_params
      params.expect(video_suggestion: [:youtube_url])
    end

    def honeypot_triggered?
      params.dig(:video_suggestion, :website).present?
    end

    def respond_to_rate_limit
      @skatepark = Skatepark.published.find_by(id: params[:skatepark_id]) unless defined?(@skatepark)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            video_suggestion_feedback_target,
            partial: 'skateparks/video_suggestion_feedback',
            locals: { skatepark: @skatepark, errors: [t('skateparks.video_suggestion.rate_limit_exceeded')] }
          ), status: :too_many_requests
        end
        format.html do
          redirect_to(@skatepark || root_path, alert: t('skateparks.video_suggestion.rate_limit_exceeded'))
        end
      end
    end

    def respond_with_success
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            video_suggestion_feedback_target,
            partial: 'skateparks/video_suggestion_feedback',
            locals: { skatepark: @skatepark, success: t('skateparks.video_suggestion.success') }
          )
        end
        format.html do
          redirect_to @skatepark, notice: t('skateparks.video_suggestion.success')
        end
      end
    end

    def respond_with_errors
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            video_suggestion_feedback_target,
            partial: 'skateparks/video_suggestion_feedback',
            locals: {
              skatepark: @skatepark,
              errors: @video_suggestion.errors.full_messages_for(:youtube_url).presence ||
                      @video_suggestion.errors.full_messages,
            }
          ), status: :unprocessable_content
        end
        format.html do
          redirect_to @skatepark, alert: @video_suggestion.errors.full_messages.to_sentence
        end
      end
    end

    def video_suggestion_feedback_target
      return 'video_suggestion_feedback' if @skatepark.blank?

      helpers.dom_id(@skatepark, :video_suggestion_feedback)
    end

    def duplicate_youtube_url_error_key
      existing = @skatepark.skatepark_videos.find_by(
        youtube_video_id: @video_suggestion.youtube_video_id,
        status: %i[pending active]
      )

      return :already_submitted if existing.blank?

      existing.active? ? :already_published : :already_pending
    end
  end
end
