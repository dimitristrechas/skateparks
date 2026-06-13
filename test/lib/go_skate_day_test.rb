# frozen_string_literal: true

require 'test_helper'

class GoSkateDayTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  def test_visible_on_may_twenty_first
    travel_to Time.zone.local(2026, 5, 21, 12) do
      assert_predicate GoSkateDay, :visible?
    end
  end

  def test_not_visible_on_may_twentieth
    travel_to Time.zone.local(2026, 5, 20, 12) do
      assert_not GoSkateDay.visible?
    end
  end

  def test_visible_on_june_twentieth
    travel_to Time.zone.local(2026, 6, 20, 12) do
      assert_predicate GoSkateDay, :visible?
    end
  end

  def test_visible_on_june_twenty_first
    travel_to Time.zone.local(2026, 6, 21, 12) do
      assert_predicate GoSkateDay, :visible?
    end
  end

  def test_not_visible_on_june_twenty_second
    travel_to Time.zone.local(2026, 6, 22, 12) do
      assert_not GoSkateDay.visible?
    end
  end

  def test_not_visible_in_january
    travel_to Time.zone.local(2026, 1, 15, 12) do
      assert_not GoSkateDay.visible?
    end
  end

  def test_celebration_day_only_on_june_twenty_first
    travel_to Time.zone.local(2026, 6, 21, 12) do
      assert_predicate GoSkateDay, :celebration_day?
    end

    travel_to Time.zone.local(2026, 6, 20, 12) do
      assert_not GoSkateDay.celebration_day?
    end
  end

  def test_days_remaining_on_may_twenty_first
    travel_to Time.zone.local(2026, 5, 21, 12) do
      assert_equal 31, GoSkateDay.days_remaining
    end
  end

  def test_days_remaining_on_june_twentieth
    travel_to Time.zone.local(2026, 6, 20, 12) do
      assert_equal 1, GoSkateDay.days_remaining
    end
  end

  def test_days_remaining_on_june_twenty_first
    travel_to Time.zone.local(2026, 6, 21, 12) do
      assert_equal 0, GoSkateDay.days_remaining
    end
  end
end
