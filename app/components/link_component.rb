class LinkComponent < ViewComponent::Base
  def initialize(title:, url:, classnames: nil, target: '_self', current: false)
    super()
    @title = title
    @url = url
    @classnames = classnames
    @target = target
    @current = current
  end

  private

  def base_classes
    'hover:underline py-1 px-2'
  end

  def current_classes
    return '' unless @current

    'underline underline-offset-2'
  end
end
