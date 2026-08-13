# frozen_string_literal: true

class IconButtonComponentPreview < ViewComponent::Preview
  def default
    render(IconButtonComponent.new(aria_label: 'Toggle website theme')) do |component|
      component.with_icon { sample_icon }
    end
  end

  private

  def sample_icon
    '<svg class="h-5 w-5" aria-hidden="true"></svg>'.html_safe
  end
end
