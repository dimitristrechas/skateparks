module Account
  class BaseController < ApplicationController
    include Authentication

    before_action :set_user

    private

    def set_user
      @user = current_user
    end

    def current_password_valid?(password)
      return true if @user.authenticate(password)

      @user.errors.add(:current_password, t('authentication.password_change_failed'))
      false
    end
  end
end
