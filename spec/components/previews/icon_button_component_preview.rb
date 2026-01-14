class IconButtonComponentPreview < ViewComponent::Preview
  # @label Default
  def default
    render(IconButtonComponent.new(aria_label: 'Menu')) do |c|
      c.with_icon { menu_icon }
    end
  end

  # @label With Data Action
  def with_data_action
    render(IconButtonComponent.new(
             aria_label: 'Toggle theme',
             id: 'theme-toggle',
             data: { action: 'click->header#toggleThemeMode' }
           )) do |c|
      c.with_icon { moon_icon }
    end
  end

  # @label With Custom ID
  def with_custom_id
    render(IconButtonComponent.new(aria_label: 'Close', id: 'close-button')) do |c|
      c.with_icon { close_icon }
    end
  end

  private

  # rubocop:disable Rails/OutputSafety
  def menu_icon
    <<~SVG.html_safe
      <svg class="size-5" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
        <path fill-rule="evenodd" d="M3 5a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zM3 10a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zM3 15a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z" clip-rule="evenodd"/>
      </svg>
    SVG
  end

  def moon_icon
    <<~SVG.html_safe
      <svg class="size-5" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
        <path d="M17.293 13.293A8 8 0 016.707 2.707a8.001 8.001 0 1010.586 10.586z"/>
      </svg>
    SVG
  end

  def close_icon
    <<~SVG.html_safe
      <svg class="size-5" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
        <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"/>
      </svg>
    SVG
  end
  # rubocop:enable Rails/OutputSafety
end
