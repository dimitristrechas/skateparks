require 'test_helper'

module Admin
  class UsersControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = create(:user, :admin)
      @regular_user = create(:user)
    end

    test 'requires admin authentication for index' do
      get admin_users_url
      assert_redirected_to new_session_path
    end

    test 'allows admin to view users index' do
      login_as @admin
      get admin_users_url
      assert_response :success
    end

    test 'allows admin to view user details' do
      login_as @admin
      get admin_user_url(@regular_user)
      assert_response :success
    end

    test 'allows admin to ban user' do
      login_as @admin
      post ban_admin_user_url(@regular_user), params: { reason: 'Spam' }

      assert_redirected_to admin_user_path(@regular_user)
      assert @regular_user.reload.banned?
      assert_equal 'Spam', @regular_user.ban_reason
    end

    test 'creates audit log when banning user' do
      login_as @admin

      assert_difference 'AuditLog.count', 1 do
        post ban_admin_user_url(@regular_user), params: { reason: 'Spam' }
      end

      log = AuditLog.last
      assert_equal @admin, log.actor
      assert_equal @regular_user, log.target
      assert_equal 'ban', log.action
      assert_equal 'Spam', log.details['reason']
    end

    test 'allows admin to unban user' do
      @regular_user.ban!(reason: 'Test')
      login_as @admin

      post unban_admin_user_url(@regular_user)

      assert_redirected_to admin_user_path(@regular_user)
      assert_not @regular_user.reload.banned?
    end

    test 'creates audit log when unbanning user' do
      @regular_user.ban!(reason: 'Test')
      login_as @admin

      assert_difference 'AuditLog.count', 1 do
        post unban_admin_user_url(@regular_user)
      end

      log = AuditLog.last
      assert_equal 'unban', log.action
    end

    test 'regular user cannot access admin users' do
      login_as @regular_user
      get admin_users_url
      assert_redirected_to root_path
      assert_match(/not authorized/, flash[:alert])
    end
  end
end
