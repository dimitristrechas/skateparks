require 'test_helper'

class PasswordResetsControllerTest < ActionDispatch::IntegrationTest
  def setup
    Rails.cache.clear
    ActionMailer::Base.deliveries.clear
  end

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
    token = user.password_reset_token
    get edit_password_reset_url(token)

    assert_response :success
  end

  test 'should reject expired token' do
    user = create(:user)
    token = user.password_reset_token
    travel 16.minutes
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
    token = user.password_reset_token
    new_password = 'newpassword12345'

    patch password_reset_url(token), params: {
      password: new_password,
      password_confirmation: new_password,
    }

    assert_redirected_to new_session_path
    assert_equal I18n.t('authentication.password_reset_success'), flash[:notice]
    assert user.reload.authenticate(new_password)
  end

  test 'should reject token after it was used to reset the password' do
    user = create(:user)
    token = user.password_reset_token
    new_password = 'newpassword12345'

    patch password_reset_url(token), params: { password: new_password, password_confirmation: new_password }
    get edit_password_reset_url(token)

    assert_redirected_to new_password_reset_path
    assert_equal I18n.t('authentication.password_reset_invalid_token'), flash[:alert]
  end

  test 'should reject a concurrent redemption whose token was consumed while waiting for the lock' do
    user = create(:user)
    session_record = user.sessions.create!(expires_at: 1.day.from_now)
    token = user.password_reset_token
    # The before_action sees a valid token; by the time the row lock is acquired another
    # request has already reset the password, so the in-lock re-check no longer matches.
    User.stubs(:find_by_password_reset_token).with(token).returns(user).then.returns(nil)

    patch password_reset_url(token), params: { password: 'newpassword12345', password_confirmation: 'newpassword12345' }

    assert_redirected_to new_password_reset_path
    assert_equal I18n.t('authentication.password_reset_invalid_token'), flash[:alert]
    assert user.reload.authenticate('password123456')
    assert Session.exists?(session_record.id)
  end

  test 'should reject blank password' do
    user = create(:user)
    session_record = user.sessions.create!(expires_at: 1.day.from_now)
    token = user.password_reset_token

    patch password_reset_url(token), params: { password: '', password_confirmation: '' }

    assert_redirected_to edit_password_reset_path(token)
    assert_equal "Password can't be blank", flash[:alert]
    assert Session.exists?(session_record.id)
  end

  test 'should reject missing password' do
    user = create(:user)
    token = user.password_reset_token

    patch password_reset_url(token)

    assert_redirected_to edit_password_reset_path(token)
    assert_equal "Password can't be blank", flash[:alert]
  end

  test 'should reject mismatched passwords' do
    user = create(:user)
    token = user.password_reset_token

    patch password_reset_url(token), params: {
      password: 'newpassword12345',
      password_confirmation: 'different123456',
    }

    assert_redirected_to edit_password_reset_path(token)
    assert_equal "Password confirmation doesn't match Password", flash[:alert]
  end

  test 'should rate limit password reset requests per ip' do
    5.times do |index|
      post password_resets_url, params: { email_address: "user-#{index}@example.com" }

      assert_redirected_to new_session_path
    end

    assert_emails 0 do
      post password_resets_url, params: { email_address: 'another@example.com' }
    end

    assert_redirected_to new_password_reset_url
    assert_equal I18n.t('authentication.rate_limit_exceeded'), flash[:alert]
  end

  test 'should rate limit password reset requests per email' do
    user = create(:user)

    3.times do
      post password_resets_url, params: { email_address: user.email_address }

      assert_redirected_to new_session_path
    end

    assert_emails 0 do
      post password_resets_url, params: { email_address: user.email_address }
    end

    assert_redirected_to new_password_reset_url
    assert_equal I18n.t('authentication.rate_limit_exceeded'), flash[:alert]
  end

  test 'should rate limit password reset completion' do
    user = create(:user)
    token = user.password_reset_token

    10.times do
      patch password_reset_url(token), params: {
        password: 'newpassword12345',
        password_confirmation: 'different123456',
      }

      assert_redirected_to edit_password_reset_path(token)
    end

    patch password_reset_url(token), params: {
      password: 'newpassword12345',
      password_confirmation: 'different123456',
    }

    assert_redirected_to edit_password_reset_path(token)
    assert_equal I18n.t('authentication.rate_limit_exceeded'), flash[:alert]
  end
end
