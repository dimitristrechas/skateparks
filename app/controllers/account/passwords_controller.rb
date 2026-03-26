module Account
  class PasswordsController < BaseController
    rate_limit to: 5, within: 15.minutes, only: :update, with: lambda {
      redirect_to edit_account_password_path,
                  alert: t('authentication.rate_limit_exceeded')
    }

    def edit
      @user = Current.session.user
    end

    def update
      @user = Current.session.user

      unless @user.authenticate(password_params[:current_password])
        @user.errors.add(:current_password, t('authentication.password_change_failed'))
        return render :edit, status: :unprocessable_content
      end

      update_password
    end

    private

    def update_password
      if @user.update(password: password_params[:password],
                      password_confirmation: password_params[:password_confirmation])
        @user.sessions.destroy_all
        cookies.delete(:session_token)
        redirect_to new_session_path, notice: t('authentication.password_changed')
      else
        render :edit, status: :unprocessable_content
      end
    end

    def password_params
      params.expect(user: %i[current_password password password_confirmation])
    end
  end
end
