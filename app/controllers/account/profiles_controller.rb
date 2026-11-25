module Account
  class ProfilesController < BaseController
    def show; end

    def edit; end

    def update
      unless current_password_valid?(params.dig(:user, :current_password))
        return render :edit, status: :unprocessable_content
      end

      if @user.update(profile_params)
        redirect_to account_profile_path, notice: t('account.profile_updated')
      else
        render :edit, status: :unprocessable_content
      end
    end

    private

    def profile_params
      params.expect(user: [:email_address])
    end
  end
end
