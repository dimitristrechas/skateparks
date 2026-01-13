class LinkButtonComponent < ViewComponent::Base
  renders_one :icon_before
  renders_one :icon_after

  def initialize(title:, url:, **options)
    @active = options.fetch(:active, false)
    @ghost = options.fetch(:ghost, false)
    @large = options.fetch(:large, false)
    raise ArgumentError, 'ghost and active cannot both be true' if @ghost && @active

    super
    @title = title
    @url = url
    @classnames = options[:classnames]
    @target = options.fetch(:target, '_self')
  end

  private

  def base_classes
    'inline-flex items-center rounded-lg py-2 px-4 min-h-11 min-w-11 ' \
      'hover:outline hover:outline-offset-1 hover:outline-neutral-700 hover:dark:outline-neutral-200'
  end

  def state_classes
    if @active
      'bg-pink-600/85 text-white dark:bg-pink-600/65 dark:text-white'
    else
      ''
    end
  end

  def ghost_classes
    return '' unless @ghost

    'outline outline-gray-400 dark:outline-gray-500 ' \
      'focus-visible:outline-neutral-700 dark:focus-visible:outline-neutral-200'
  end

  def large_classes
    return '' unless @large

    'text-xl px-6 py-3'
  end
end
