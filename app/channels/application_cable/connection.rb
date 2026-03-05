module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      set_current_user || reject_unauthorized_connection
    end

    private

    def set_current_user
      session = Session.find_by(session_token: cookies.signed[:session_token])
      return nil unless session
      return nil if session.expired?
      return nil unless session.user.active?

      self.current_user = session.user
    end
  end
end
