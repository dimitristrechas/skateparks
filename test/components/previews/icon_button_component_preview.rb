# frozen_string_literal: true

class IconButtonComponentPreview < ViewComponent::Preview
  def default
    render(IconButtonComponent.new(aria_label: 'Toggle website theme')) do |component|
      component.with_icon { sample_icon }
    end
  end

  private

  def sample_icon
    tag.svg(
      class: 'h-5 w-5',
      viewBox: '0 0 20 20',
      fill: 'currentColor',
      aria: { hidden: true }
    ) do
      tag.path(d: 'M17.293 13.293A8 8 0 016.707 2.707a8.001 8.001 0 1010.586 10.586z')
    end
  end
end
