class HomeController < ApplicationController
  def index
    @skateparks = Skatepark.published.order(created_at: :desc)
    @skateparks_latest = Rails.cache.fetch(Skatepark.homepage_latest_cache_key, expires_in: 1.year) do
      Skatepark.latest.includes(:skatepark_images, cover_image_attachment: :blob).to_a
    end
    @skateparks_popular = Rails.cache.fetch(Skatepark.homepage_popular_cache_key, expires_in: 1.year) do
      Skatepark.popular.includes(:skatepark_images, cover_image_attachment: :blob).to_a
    end

    agent_debug_log_homepage_skatepark_video_count!(@skateparks_latest, @skateparks_popular)

    @locale = params['locale']
  end

  def about
    @title = t('about')
    @meta_description = t('about_details')
  end

  def contact
    @title = t('contact')
    @meta_description = t('contact_details')
  end

  private

  # #region agent log
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity -- temporary debug instrumentation
  def agent_debug_log_homepage_skatepark_video_count!(skateparks_latest, skateparks_popular)
    %w[latest popular].each do |which|
      list = which == 'latest' ? skateparks_latest : skateparks_popular
      sp = list&.first
      missing = false
      begin
        sp&.skatepark_videos_count
      rescue ActiveModel::MissingAttributeError
        missing = true
      end
      payload = {
        sessionId: 'adbdc8',
        hypothesisId: 'H1',
        runId: ENV['DEBUG_RUN_ID'] || 'pre-fix',
        location: 'home_controller.rb:index',
        message: 'skatepark_videos_count_readable',
        data: { which: which, first_id: sp&.id, missing_attribute: missing, class_name: sp&.class&.name },
        timestamp: (Time.now.to_f * 1000).to_i,
      }
      begin
        File.open('/Users/A200269715/dev/skateparks/.cursor/debug-adbdc8.log', 'a') { |f| f.puts(payload.to_json) }
      rescue StandardError
        nil
      end
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  # #endregion
end
