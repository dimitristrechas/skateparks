module Admin
  class BaseController < ApplicationController
    include Authentication

    before_action :ensure_admin

    private

    def ensure_admin
      return if current_user&.admin?

      flash[:alert] = t('application.not_authorized')
      redirect_to root_path
    end
  end
end
