# frozen_string_literal: true

class GoSkateDayCountdownComponent < ViewComponent::Base
  def initialize(date: Time.zone.today)
    super()
    @date = date.to_date
  end

  def render?
    GoSkateDay.visible?(@date)
  end

  def celebration_day?
    GoSkateDay.celebration_day?(@date)
  end

  def days_remaining
    GoSkateDay.days_remaining(@date)
  end

  def aria_label
    if celebration_day?
      t('home.go_skate_day.aria_label_today')
    else
      t('home.go_skate_day.aria_label_countdown', count: days_remaining)
    end
  end

  def message
    if celebration_day?
      t('home.go_skate_day.today')
    else
      t('home.go_skate_day.countdown', count: days_remaining)
    end
  end
end
