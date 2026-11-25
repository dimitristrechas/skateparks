require 'test_helper'

class SessionTest < ActiveSupport::TestCase
  test 'find_active_by_token returns a live session' do
    session = create(:user).sessions.create!(expires_at: 1.day.from_now)

    assert_equal session, Session.find_active_by_token(session.session_token)
  end

  test 'find_active_by_token ignores blank, expired, and banned-user sessions' do
    user = create(:user)
    expired = user.sessions.create!(expires_at: 1.minute.ago)
    banned_session = create(:user, banned_at: Time.current).sessions.create!(expires_at: 1.day.from_now)

    assert_nil Session.find_active_by_token(nil)
    assert_nil Session.find_active_by_token(expired.session_token)
    assert_nil Session.find_active_by_token(banned_session.session_token)
  end
end
