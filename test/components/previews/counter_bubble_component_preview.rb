# frozen_string_literal: true

class CounterBubbleComponentPreview < ViewComponent::Preview
  def default
    render(CounterBubbleComponent.new(count: 12, label: 'Photos'))
  end
end
