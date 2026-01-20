class ButtonComponentPreview < ViewComponent::Preview
  # @label Default
  def default
    render(ButtonComponent.new(title: 'Submit', type: :submit))
  end

  # @label Ghost
  def ghost
    render(ButtonComponent.new(title: 'Cancel', type: :button, ghost: true))
  end

  # @label Large
  def large
    render(ButtonComponent.new(title: 'Large Button', type: :button, large: true))
  end
end
