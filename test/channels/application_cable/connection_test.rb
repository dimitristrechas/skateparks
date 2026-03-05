require 'test_helper'

module ApplicationCable
  class ConnectionTest < ActionCable::Connection::TestCase
    def test_inherits_from_action_cable_connection_base
      assert_equal ActionCable::Connection::Base, ApplicationCable::Connection.superclass
    end

    test 'connects with valid session' do
      user = create(:user)
      session = user.sessions.create!(
        user_agent: 'Test',
        ip_address: '127.0.0.1',
        expires_at: 2.weeks.from_now
      )

      cookies.signed[:session_token] = session.session_token

      connect

      assert_equal user.id, connection.current_user.id
    end

    test 'rejects connection without session' do
      assert_reject_connection { connect }
    end

    test 'rejects connection with expired session' do
      user = create(:user)
      session = user.sessions.create!(
        user_agent: 'Test',
        ip_address: '127.0.0.1',
        expires_at: 1.minute.ago
      )

      cookies.signed[:session_token] = session.session_token

      assert_reject_connection { connect }
    end

    test 'rejects connection for banned user' do
      user = create(:user, :banned)
      session = user.sessions.create!(
        user_agent: 'Test',
        ip_address: '127.0.0.1',
        expires_at: 2.weeks.from_now
      )

      cookies.signed[:session_token] = session.session_token

      assert_reject_connection { connect }
    end
  end
end
