# frozen_string_literal: true

class ButtonComponentPreview < ViewComponent::Preview
  def default
    render(ButtonComponent.new(title: 'Submit', type: :submit))
  end

  def ghost
    render(ButtonComponent.new(title: 'Cancel', type: :button, ghost: true))
  end

  def large
    render(ButtonComponent.new(title: 'Save changes', type: :submit, large: true))
  end
end
