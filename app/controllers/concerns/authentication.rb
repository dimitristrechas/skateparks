module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?, :current_user
  end

  class_methods do
    def allow_unauthenticated_access(**)
      skip_before_action :require_authentication, **
    end
  end

  private

  def authenticated?
    resume_session
  end

  def current_user
    Current.session&.user
  end

  def require_authentication
    resume_session || request_authentication
  end

  def resume_session
    Current.session ||= Session.find_active_by_token(cookies.signed[:session_token])
  end

  def request_authentication
    session[:return_to_after_authenticating] = request.url
    redirect_to new_session_path
  end

  def after_authentication_url
    return_url = session.delete(:return_to_after_authenticating)
    return return_url if return_url.present?
    return admin_root_url if current_user&.admin?

    root_url
  end

  def start_new_session_for(user)
    return unless user.active?

    reset_session_preserving_return_to

    user.sessions.create!(
      user_agent: request.user_agent,
      ip_address: request.remote_ip,
      expires_at: 2.weeks.from_now
    ).tap do |user_session|
      Current.session = user_session
      cookies.signed[:session_token] = {
        value: user_session.session_token,
        expires: 2.weeks,
        httponly: true,
        secure: Rails.env.production?,
        same_site: :lax,
      }
    end
  end

  def reset_session_preserving_return_to
    return_to = session[:return_to_after_authenticating]
    reset_session
    session[:return_to_after_authenticating] = return_to if return_to
  end

  def terminate_session
    Current.session.destroy
    cookies.delete(:session_token)
  end
end
