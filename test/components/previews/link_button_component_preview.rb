# frozen_string_literal: true

class LinkButtonComponentPreview < ViewComponent::Preview
  def default
    render(LinkButtonComponent.new(title: 'Explore skateparks', url: '/skateparks'))
  end

  def contained
    render(LinkButtonComponent.new(title: 'Get started', url: '/skateparks', contained: true))
  end

  def ghost
    render(LinkButtonComponent.new(title: 'Learn more', url: '/about', ghost: true))
  end

  def current
    render(LinkButtonComponent.new(title: 'Home', url: '/', current: true))
  end
end
