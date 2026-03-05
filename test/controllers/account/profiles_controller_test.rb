require 'test_helper'

module Account
  class ProfilesControllerTest < ActionDispatch::IntegrationTest
    test 'requires authentication for show' do
      get account_profile_url
      assert_redirected_to new_session_path
    end

    test 'requires authentication for edit' do
      get edit_account_profile_url
      assert_redirected_to new_session_path
    end

    test 'requires authentication for update' do
      patch account_profile_url, params: { user: { email_address: 'new@example.com' } }
      assert_redirected_to new_session_path
    end

    test 'show displays current user email' do
      user = create(:user, email_address: 'current@example.com')
      sign_in_as(user)
      get account_profile_url
      assert_response :success
      assert_select 'body', text: /current@example\.com/
    end

    test 'edit displays form' do
      user = create(:user, email_address: 'current@example.com')
      sign_in_as(user)
      get edit_account_profile_url
      assert_response :success
      assert_select 'form'
    end

    test 'update email success' do
      user = create(:user, email_address: 'old@example.com')
      sign_in_as(user)
      patch account_profile_url, params: { user: { email_address: 'new@example.com' } }
      assert_redirected_to account_profile_path
      assert_equal 'new@example.com', user.reload.email_address
      follow_redirect!
      assert_match(/Profile updated/, response.body)
    end

    test 'update email with invalid email fails' do
      user = create(:user, email_address: 'valid@example.com')
      sign_in_as(user)
      patch account_profile_url, params: { user: { email_address: '' } }
      assert_response :unprocessable_entity
      assert_equal 'valid@example.com', user.reload.email_address
    end

    test 'update normalizes email' do
      user = create(:user, email_address: 'old@example.com')
      sign_in_as(user)
      patch account_profile_url, params: { user: { email_address: '  NEW@EXAMPLE.COM  ' } }
      assert_redirected_to account_profile_path
      assert_equal 'new@example.com', user.reload.email_address
    end

    test 'admin sees back to admin link on profile' do
      admin = create(:user, :admin)
      sign_in_as(admin)
      get account_profile_url
      assert_match(I18n.t('back_to_admin'), response.body)
    end

    test 'regular user does not see back to admin link on profile' do
      user = create(:user)
      sign_in_as(user)
      get account_profile_url
      assert_no_match(I18n.t('back_to_admin'), response.body)
    end

    private

    def sign_in_as(user)
      login_as(user)
    end
  end
end
