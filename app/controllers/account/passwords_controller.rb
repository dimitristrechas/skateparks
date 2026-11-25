module Account
  class PasswordsController < BaseController
    rate_limit to: 5, within: 15.minutes, only: :update, with: lambda {
      redirect_to edit_account_password_path,
                  alert: t('authentication.rate_limit_exceeded')
    }

    def edit; end

    def update
      unless current_password_valid?(password_params[:current_password])
        return render :edit, status: :unprocessable_content
      end

      if @user.update(password: password_params[:password],
                      password_confirmation: password_params[:password_confirmation])
        @user.sessions.destroy_all
        cookies.delete(:session_token)
        redirect_to new_session_path, notice: t('authentication.password_changed')
      else
        render :edit, status: :unprocessable_content
      end
    end

    private

    def password_params
      params.expect(user: %i[current_password password password_confirmation])
    end
  end
end
