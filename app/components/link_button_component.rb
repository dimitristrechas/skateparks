class LinkButtonComponent < ViewComponent::Base
  def initialize(title:, url:, **options)
    @active = options.fetch(:active, false)
    @ghost = options.fetch(:ghost, false)
    raise ArgumentError, 'ghost and active cannot both be true' if @ghost && @active

    super
    @title = title
    @url = url
    @classnames = options[:classnames]
    @target = options.fetch(:target, '_self')
  end

  private

  def base_classes
    'rounded-lg py-2 px-4 min-h-11 min-w-11 ' \
      'hover:outline hover:outline-offset-1 hover:outline-neutral-700 hover:dark:outline-neutral-200'
  end

  def state_classes
    if @active
      'bg-gray-200 text-gray-900 font-semibold dark:bg-gray-800 dark:text-neutral-100'
    else
      ''
    end
  end

  def ghost_classes
    return '' unless @ghost

    'outline outline-gray-400 dark:outline-gray-500 ' \
      'focus-visible:outline-neutral-700 dark:focus-visible:outline-neutral-200'
  end
end
