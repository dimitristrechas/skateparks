class PasswordResetsController < ApplicationController
  include Authentication

  allow_unauthenticated_access
  rate_limit to: 5, within: 15.minutes, only: :create, with: lambda {
    redirect_to new_password_reset_url, alert: t('authentication.rate_limit_exceeded')
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
    if @user.update(params.permit(:password, :password_confirmation))
      @user.sessions.destroy_all
      redirect_to new_session_path, notice: t('authentication.password_reset_success')
    else
      redirect_to edit_password_reset_path(params[:token]), alert: t('authentication.password_reset_failed')
    end
  end

  private

  def set_user_by_token
    @user = User.find_signed(params[:token], purpose: :password_reset)
    redirect_to new_password_reset_path, alert: t('authentication.password_reset_invalid_token') if @user.nil?
  end
end
