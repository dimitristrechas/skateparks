class PasswordResetsController < ApplicationController
  include Authentication

  allow_unauthenticated_access
  rate_limit to: 5, within: 15.minutes, only: :create, name: 'per-ip', with: lambda {
    redirect_to new_password_reset_url, alert: t('authentication.rate_limit_exceeded')
  }
  rate_limit to: 3, within: 15.minutes, only: :create, name: 'per-email', by: lambda {
    params[:email_address].to_s.downcase.strip
  }, with: lambda {
    redirect_to new_password_reset_url, alert: t('authentication.rate_limit_exceeded')
  }
  rate_limit to: 10, within: 15.minutes, only: :update, with: lambda {
    redirect_to edit_password_reset_path(params[:token]), alert: t('authentication.rate_limit_exceeded')
  }
  before_action :set_user_by_token, only: %i[edit update]

  def new; end

  def edit; end

  def create
    user = User.find_by(email_address: params[:email_address])
    PasswordsMailer.reset(user).deliver_later if user

    redirect_to new_session_path, notice: t('authentication.password_reset_sent')
  end

  def update
    case redeem_password_reset
    when :updated
      @user.sessions.destroy_all
      redirect_to new_session_path, notice: t('authentication.password_reset_success')
    when :invalid_token
      redirect_to new_password_reset_path, alert: t('authentication.password_reset_invalid_token')
    else
      alert = @user.errors.full_messages.to_sentence.presence || t('authentication.password_reset_failed')
      redirect_to edit_password_reset_path(params[:token]), alert: alert
    end
  end

  private

  # Re-checks the token under a row lock so concurrent redemptions of one token cannot both succeed:
  # the first commit rotates password_salt, which invalidates the token for the waiting request.
  def redeem_password_reset
    @user.with_lock do
      next :invalid_token unless User.find_by_password_reset_token(params[:token]) == @user

      updated = @user.update(password: params[:password], password_confirmation: params[:password_confirmation])
      updated ? :updated : :failed
    end
  end

  def set_user_by_token
    @user = User.find_by_password_reset_token(params[:token])
    redirect_to new_password_reset_path, alert: t('authentication.password_reset_invalid_token') if @user.nil?
  end
end
