# frozen_string_literal: true

require 'test_helper'

class GoSkateDayCountdownComponentTest < ViewComponent::TestCase
  include ActiveSupport::Testing::TimeHelpers

  MESSAGE_ID = '#go-skate-day-countdown-message'

  def test_does_not_render_outside_visibility_window
    travel_to Time.zone.local(2026, 5, 20, 12) do
      render_inline(GoSkateDayCountdownComponent.new)

      assert_no_selector '[role="region"]'
    end
  end

  def test_renders_countdown_message_in_english
    travel_to Time.zone.local(2026, 6, 10, 12) do
      I18n.with_locale(:en) do
        render_inline(GoSkateDayCountdownComponent.new)

        region = page.find('[role="region"]')

        assert_equal 'go-skate-day-countdown-message', region['aria-labelledby']
        assert_selector MESSAGE_ID, text: I18n.t('home.go_skate_day.countdown', count: 11)
      end
    end
  end

  def test_renders_countdown_message_in_greek
    travel_to Time.zone.local(2026, 6, 10, 12) do
      I18n.with_locale(:el) do
        render_inline(GoSkateDayCountdownComponent.new)

        region = page.find('[role="region"]')

        assert_equal 'go-skate-day-countdown-message', region['aria-labelledby']
        assert_selector MESSAGE_ID, text: I18n.t('home.go_skate_day.countdown', count: 11)
      end
    end
  end

  def test_renders_singular_countdown_on_june_twentieth_in_english
    travel_to Time.zone.local(2026, 6, 20, 12) do
      I18n.with_locale(:en) do
        render_inline(GoSkateDayCountdownComponent.new)

        assert_selector MESSAGE_ID, text: I18n.t('home.go_skate_day.countdown', count: 1)
      end
    end
  end

  def test_renders_singular_countdown_on_june_twentieth_in_greek
    travel_to Time.zone.local(2026, 6, 20, 12) do
      I18n.with_locale(:el) do
        render_inline(GoSkateDayCountdownComponent.new)

        assert_selector MESSAGE_ID, text: I18n.t('home.go_skate_day.countdown', count: 1)
      end
    end
  end

  def test_renders_celebration_message_on_june_twenty_first
    travel_to Time.zone.local(2026, 6, 21, 12) do
      I18n.with_locale(:en) do
        render_inline(GoSkateDayCountdownComponent.new)

        region = page.find('[role="region"]')

        assert_equal 'go-skate-day-countdown-message', region['aria-labelledby']
        assert_selector MESSAGE_ID, text: I18n.t('home.go_skate_day.today')
      end
    end
  end

  def test_renders_decorative_skateboard_emoji
    travel_to Time.zone.local(2026, 6, 10, 12) do
      render_inline(GoSkateDayCountdownComponent.new)

      assert_selector 'span[aria-hidden="true"]', text: '🛹'
    end
  end

  def test_accepts_injected_date
    render_inline(GoSkateDayCountdownComponent.new(date: Date.new(2026, 6, 15)))

    assert_selector MESSAGE_ID, text: I18n.t('home.go_skate_day.countdown', count: 6)
  end
end
