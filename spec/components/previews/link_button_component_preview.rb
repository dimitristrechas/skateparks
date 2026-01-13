class LinkButtonComponentPreview < ViewComponent::Preview
  # @label Default
  def default
    render(LinkButtonComponent.new(title: 'Click me', url: '#'))
  end

  # @label Active
  def active
    render(LinkButtonComponent.new(title: 'Current Page', url: '#', active: true))
  end

  # @label Ghost
  def ghost
    render(LinkButtonComponent.new(title: 'Ghost Button', url: '#', ghost: true))
  end

  # @label External Link
  def external
    render(LinkButtonComponent.new(title: 'Open External', url: 'https://example.com', target: '_blank'))
  end
end
