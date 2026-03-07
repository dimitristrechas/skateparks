require 'test_helper'

class PasswordResetsControllerTest < ActionDispatch::IntegrationTest
  test 'should get new password reset form' do
    get new_password_reset_url

    assert_response :success
  end

  test 'should send password reset email for existing user' do
    user = create(:user)
    assert_emails 1 do
      post password_resets_url, params: { email_address: user.email_address }
    end
    assert_redirected_to new_session_path
    assert_equal I18n.t('authentication.password_reset_sent'), flash[:notice]
  end

  test 'should show generic message for non-existent email' do
    post password_resets_url, params: { email_address: 'nonexistent@example.com' }

    assert_redirected_to new_session_path
    assert_equal I18n.t('authentication.password_reset_sent'), flash[:notice]
  end

  test 'should access edit form with valid token' do
    user = create(:user)
    token = user.generate_password_reset_token
    get edit_password_reset_url(token)

    assert_response :success
  end

  test 'should reject expired token' do
    user = create(:user)
    token = user.signed_id(expires_in: -1.minute, purpose: :password_reset)
    get edit_password_reset_url(token)

    assert_redirected_to new_password_reset_path
    assert_equal I18n.t('authentication.password_reset_invalid_token'), flash[:alert]
  end

  test 'should reject invalid token' do
    get edit_password_reset_url('invalid-token')

    assert_redirected_to new_password_reset_path
    assert_equal I18n.t('authentication.password_reset_invalid_token'), flash[:alert]
  end

  test 'should update password with valid token' do
    user = create(:user)
    token = user.generate_password_reset_token
    new_password = 'newpassword12345'

    patch password_reset_url(token), params: {
      password: new_password,
      password_confirmation: new_password,
    }

    assert_redirected_to new_session_path
    assert_equal I18n.t('authentication.password_reset_success'), flash[:notice]
    assert user.reload.authenticate(new_password)
  end

  test 'should reject mismatched passwords' do
    user = create(:user)
    token = user.generate_password_reset_token

    patch password_reset_url(token), params: {
      password: 'newpassword12345',
      password_confirmation: 'different123456',
    }

    assert_redirected_to edit_password_reset_path(token)
    assert_equal I18n.t('authentication.password_reset_failed'), flash[:alert]
  end
end
