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

    test 'filters users index by email search query' do
      matching_user = create(:user, email_address: 'skater.kavala@example.com')
      other_user = create(:user, email_address: 'other.person@example.com')
      login_as @admin

      get admin_users_url, params: { q: 'KAVALA' }

      assert_response :success
      assert_includes assigns(:users), matching_user
      assert_not_includes assigns(:users), other_user
    end

    test 'paginates users index' do
      Kaminari.config.stubs(:default_per_page).returns(1)
      login_as @admin

      get admin_users_url

      assert_response :success
      assert_equal 1, assigns(:users).size
      assert_select "nav[aria-label='#{I18n.t('views.pagination.aria_label')}']"
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
      assert_predicate @regular_user.reload, :banned?
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

    test 'admin cannot ban themselves' do
      login_as @admin

      assert_no_difference 'AuditLog.count' do
        post ban_admin_user_url(@admin), params: { reason: 'Self ban attempt' }
      end

      assert_redirected_to admin_user_path(@admin)
      assert_equal I18n.t('admin.users.ban_self_forbidden'), flash[:alert]
      assert_not @admin.reload.banned?
    end

    test 'regular user cannot access admin users' do
      login_as @regular_user
      get admin_users_url

      assert_redirected_to root_path
      assert_match(/not authorized/, flash[:alert])
    end
  end
end
