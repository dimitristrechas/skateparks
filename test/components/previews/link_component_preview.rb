# frozen_string_literal: true

class LinkComponentPreview < ViewComponent::Preview
  def default
    render(LinkComponent.new(title: 'About', url: '/about'))
  end

  def current
    render(LinkComponent.new(title: 'About', url: '/about', current: true))
  end
end
