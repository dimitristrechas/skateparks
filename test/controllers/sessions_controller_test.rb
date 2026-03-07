require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test 'login success for active user' do
    user = create(:user, email_address: 'active@example.com', password: 'password123456')
    post session_url, params: { email_address: 'active@example.com', password: 'password123456' }

    assert_redirected_to root_path
    assert Session.exists?(user_id: user.id)
  end

  test 'login failure for invalid credentials' do
    post session_url, params: { email_address: 'wrong@example.com', password: 'wrong' }

    assert_redirected_to new_session_path
    assert_equal I18n.t('authentication.invalid_credentials'), flash[:alert]
  end

  test 'login blocked for banned user shows generic error' do
    user = create(:user, email_address: 'banned@example.com', password: 'password123456')
    user.ban!(reason: 'Spam')
    post session_url, params: { email_address: 'banned@example.com', password: 'password123456' }

    assert_redirected_to new_session_path
    assert_equal I18n.t('authentication.invalid_credentials'), flash[:alert]
    assert_not Session.exists?(user_id: user.id)
  end

  test 'prevents user enumeration by running dummy BCrypt when email not found' do
    BCrypt::Password.expects(:create).with('dummy', cost: BCrypt::Engine::DEFAULT_COST).once
    post session_url, params: { email_address: 'nonexistent@example.com', password: 'password123456' }

    assert_redirected_to new_session_path
  end

  test 'does not run dummy BCrypt when email exists' do
    create(:user, email_address: 'exists@example.com', password: 'password123456')
    BCrypt::Password.expects(:create).never
    post session_url, params: { email_address: 'exists@example.com', password: 'wrongpassword123' }

    assert_redirected_to new_session_path
  end

  test 'session resumption grants access to protected page' do
    user = create(:user)
    post session_url, params: { email_address: user.email_address, password: 'password123456' }
    follow_redirect!

    assert_response :success
  end

  test 'logout' do
    user = create(:user)
    post session_url, params: { email_address: user.email_address, password: 'password123456' }
    session = Session.find_by(user_id: user.id)

    assert_not_nil session

    delete session_url

    assert_redirected_to new_session_path
    assert_not Session.exists?(session.id)
  end
end
