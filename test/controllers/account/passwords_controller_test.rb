require 'test_helper'

module Account
  class PasswordsControllerTest < ActionDispatch::IntegrationTest
    test 'requires authentication for edit' do
      get edit_account_password_url

      assert_redirected_to new_session_path
    end

    test 'requires authentication for update' do
      patch account_password_url,
            params: { user: { current_password: 'old', password: 'new', password_confirmation: 'new' } }

      assert_redirected_to new_session_path
    end

    test 'edit displays password form' do
      user = create(:user)
      sign_in_as(user)
      get edit_account_password_url

      assert_response :success
      assert_select 'form'
    end

    test 'update password success' do
      user = create(:user)
      sign_in_as(user)
      patch account_password_url, params: {
        user: {
          current_password: 'password123456',
          password: 'newpassword12345',
          password_confirmation: 'newpassword12345',
        },
      }

      assert_redirected_to new_session_path
      assert user.reload.authenticate('newpassword12345')
      follow_redirect!

      assert_match(/Password updated/, response.body)
    end

    test 'update password requires current password' do
      user = create(:user)
      sign_in_as(user)
      patch account_password_url, params: {
        user: {
          current_password: 'wrongpassword',
          password: 'newpassword12345',
          password_confirmation: 'newpassword12345',
        },
      }

      assert_response :unprocessable_entity
      assert_not user.reload.authenticate('newpassword12345')
      assert_match(/incorrect/, response.body)
    end

    test 'update password requires matching confirmation' do
      user = create(:user)
      sign_in_as(user)
      patch account_password_url, params: {
        user: {
          current_password: 'password123456',
          password: 'newpassword12345',
          password_confirmation: 'differentpass123',
        },
      }

      assert_response :unprocessable_entity
      assert_not user.reload.authenticate('newpassword12345')
    end

    test 'update password requires valid new password' do
      user = create(:user)
      sign_in_as(user)
      patch account_password_url, params: {
        user: {
          current_password: 'password123456',
          password: 'short',
          password_confirmation: 'short',
        },
      }

      assert_response :unprocessable_entity
    end

    private

    def sign_in_as(user)
      login_as(user)
    end
  end
end
