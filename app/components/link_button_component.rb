class LinkButtonComponent < ViewComponent::Base
  def initialize(title:, url:, classnames: nil, target: '_self', active: false)
    super
    @title = title
    @url = url
    @classnames = classnames
    @target = target
    @active = active
  end

  private

  def base_classes
    'rounded-lg py-2 px-4 focus-visible:outline-2 focus-visible:outline-offset-2 ' \
      'focus-visible:outline-neutral-700 dark:focus-visible:outline-neutral-200'
  end

  def state_classes
    if @active
      'outline outline-gray-200 bg-gray-200 dark:outline-gray-800 dark:bg-gray-800'
    else
      'hover:outline hover:outline-gray-200 hover:bg-gray-200 dark:hover:outline-gray-800 dark:hover:bg-gray-800'
    end
  end
end
