module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[show ban unban]

    def index
      @users = User.order(created_at: :desc)
    end

    def show
      @sessions = @user.sessions.order(created_at: :desc)
      @audit_logs = AuditLog.where(target: @user).order(created_at: :desc).limit(20)
    end

    def ban
      return redirect_to admin_user_path(@user), alert: t('admin.users.ban_self_forbidden') if @user == current_user

      @user.ban!(reason: params[:reason])
      log_audit_action(:ban, reason: params[:reason])
      redirect_to admin_user_path(@user), notice: t('admin.users.ban_success')
    rescue ActiveRecord::RecordInvalid
      redirect_to admin_user_path(@user), alert: t('admin.users.ban_failed')
    end

    def unban
      if @user.update(banned_at: nil, ban_reason: nil)
        log_audit_action(:unban)
        redirect_to admin_user_path(@user), notice: t('admin.users.unban_success')
      else
        redirect_to admin_user_path(@user), alert: t('admin.users.unban_failed')
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def log_audit_action(action, details = {})
      AuditLog.create!(
        actor: current_user,
        target: @user,
        action: action,
        details: details
      )
    end
  end
end
