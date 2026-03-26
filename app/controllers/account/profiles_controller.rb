module Account
  class ProfilesController < BaseController
    def show
      @user = Current.session.user
    end

    def edit
      @user = Current.session.user
    end

    def update
      @user = Current.session.user

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
