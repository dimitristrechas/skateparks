# frozen_string_literal: true

require 'test_helper'

class ApplicationJobTest < ActiveSupport::TestCase
  def test_inherits_from_active_job_base
    assert_equal ActiveJob::Base, ApplicationJob.superclass
  end
end
