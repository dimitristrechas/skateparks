require 'test_helper'

class SessionCleanupWorkerTest < ActiveSupport::TestCase
  test 'deletes expired sessions' do
    user = create(:user)
    expired_session = user.sessions.create!(
      user_agent: 'Test',
      ip_address: '127.0.0.1',
      expires_at: 1.day.ago
    )
    active_session = user.sessions.create!(
      user_agent: 'Test',
      ip_address: '127.0.0.1',
      expires_at: 1.day.from_now
    )

    SessionCleanupWorker.new.perform

    assert_not Session.exists?(expired_session.id)
    assert Session.exists?(active_session.id)
  end

  test 'does not delete active sessions' do
    user = create(:user)
    session = user.sessions.create!(
      user_agent: 'Test',
      ip_address: '127.0.0.1',
      expires_at: 2.weeks.from_now
    )

    SessionCleanupWorker.new.perform

    assert Session.exists?(session.id)
  end
end
