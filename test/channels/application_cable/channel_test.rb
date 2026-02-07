require 'test_helper'

module ApplicationCable
  class ChannelTest < ActionCable::Channel::TestCase
    def test_inherits_from_action_cable_channel_base
      assert_equal ActionCable::Channel::Base, ApplicationCable::Channel.superclass
    end
  end
end
