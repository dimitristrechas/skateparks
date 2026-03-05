module Account
  class ProfilesController < BaseController
    def show
      @user = Current.session.user
    end

    def edit
      redirect_to account_profile_path
    end

    def update
      @user = Current.session.user

      if @user.update(profile_params)
        redirect_to account_profile_path, notice: t('account.profile_updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def profile_params
      params.expect(user: [])
    end
  end
end
