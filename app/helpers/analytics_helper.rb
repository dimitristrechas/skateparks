module AnalyticsHelper
  def cookie_consent_enabled?
    return false if request.path.start_with?('/admin')
    return false if ENV['POSTHOG_API_KEY'].blank?

    true
  end

  def posthog_enabled?
    cookie_consent_enabled? && Rails.env.production?
  end
end
