# frozen_string_literal: true

class GoSkateDayCountdownComponentPreview < ViewComponent::Preview
  def countdown
    render(GoSkateDayCountdownComponent.new(date: Date.new(2026, 6, 1)))
  end

  def celebration
    render(GoSkateDayCountdownComponent.new(date: Date.new(2026, 6, 21)))
  end
end
