require 'test_helper'

module ApplicationCable
  class ConnectionTest < ActionCable::Connection::TestCase
    def test_inherits_from_action_cable_connection_base
      assert_equal ActionCable::Connection::Base, ApplicationCable::Connection.superclass
    end
  end
end
