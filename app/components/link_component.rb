class LinkComponent < ViewComponent::Base
  def initialize(title:, url:, classnames: nil, target: '_self')
    super
    @title = title
    @url = url
    @classnames = classnames
    @target = target
  end
end
