module AnalyticsHelper
  def posthog_enabled?
    return false if request.path.start_with?('/admin')
    return false if ENV['POSTHOG_API_KEY'].blank?

    Rails.env.production?
  end
end
