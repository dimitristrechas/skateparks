class SessionsController < ApplicationController
  include Authentication

  allow_unauthenticated_access only: %i[new create]
  rate_limit to: 10, within: 3.minutes, only: :create, name: 'per-ip', with: lambda {
    redirect_to new_session_url, alert: t('authentication.rate_limit_exceeded')
  }
  rate_limit to: 10, within: 3.minutes, only: :create, name: 'per-email', by: lambda {
    params[:email_address].to_s.downcase.strip
  }, with: lambda {
    redirect_to new_session_url, alert: t('authentication.rate_limit_exceeded')
  }

  def new; end

  def create
    user = authenticate_user
    if user
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: t('authentication.invalid_credentials')
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end

  private

  def authenticate_user
    user = User.find_by(email_address: params[:email_address])

    unless user
      BCrypt::Password.create('dummy', cost: BCrypt::Engine::DEFAULT_COST)
      return nil
    end

    return nil unless user.authenticate(params[:password])
    return nil unless user.active?

    user
  end
end
