require 'test_helper'

class ApplicationMailerTest < ActionMailer::TestCase
  def test_sets_default_from_address
    assert_equal 'from@example.com', ApplicationMailer.default[:from]
  end

  def test_uses_mailer_layout
    assert_equal 'mailer', ApplicationMailer._layout
  end
end
