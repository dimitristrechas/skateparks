class LinkComponentPreview < ViewComponent::Preview
  # @label Default
  def default
    render(LinkComponent.new(title: 'About us', url: '#'))
  end

  # @label Current (Active Page)
  def current
    render(LinkComponent.new(title: 'Home', url: '#', current: true))
  end

  # @label External Link
  def external
    render(LinkComponent.new(title: 'Visit GitHub', url: 'https://github.com', target: '_blank'))
  end

  # @label With Custom Classes
  def with_custom_classes
    render(LinkComponent.new(title: 'Styled Link', url: '#', classnames: 'text-lg font-bold text-pink-500'))
  end
end
