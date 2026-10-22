module SkateparkVisitTracking
  extend ActiveSupport::Concern

  BOT_USER_AGENT_PATTERN = Regexp.union(
    /bot|crawl|spider|slurp|mediapartners|facebookexternalhit|whatsapp|telegrambot/i,
    /twitterbot|discordbot|linkedinbot|embedly|quora|pinterest|slackbot|vkshare/i,
    /outbrain|w3c_validator|lighthouse|headlesschrome/i
  ).freeze
  MAX_TRACKED_SKATEPARK_IDS = 50

  private

  def track_skatepark_visit
    return unless trackable_visit_request?

    viewed_ids = viewed_skatepark_ids
    return if viewed_ids.include?(@skatepark.id)

    increment_skatepark_visits(viewed_ids)
  end

  def increment_skatepark_visits(viewed_ids)
    Skatepark.increment_counter(:visits_count, @skatepark.id) # rubocop:disable Rails/SkipsModelValidations
    @skatepark.visits_count += 1
    session[:viewed_skatepark_ids] = [*viewed_ids, @skatepark.id].last(MAX_TRACKED_SKATEPARK_IDS)
  end

  def viewed_skatepark_ids
    Array(session[:viewed_skatepark_ids]).map(&:to_i)
  end

  def trackable_visit_request?
    request.get? && !request.head? && !bot_request? && !prefetch_request?
  end

  def bot_request?
    request.user_agent.to_s.match?(BOT_USER_AGENT_PATTERN)
  end

  def prefetch_request?
    purpose = [request.headers['Sec-Purpose'], request.headers['X-Sec-Purpose']].join(' ').downcase
    moz = request.headers['X-Moz'].to_s.downcase
    purpose.include?('prefetch') || purpose.include?('preview') || moz == 'prefetch'
  end
end
