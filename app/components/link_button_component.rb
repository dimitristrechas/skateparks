class LinkButtonComponent < ViewComponent::Base
  renders_one :icon_before
  renders_one :icon_after

  def initialize(title:, url:, **options)
    @current = options.fetch(:current, false)
    @contained = options.fetch(:contained, false)
    @ghost = options.fetch(:ghost, false)
    @large = options.fetch(:large, false)
    styles = { ghost: @ghost, contained: @contained, current: @current }.select { |_, v| v }
    raise ArgumentError, 'only one of ghost, contained, current can be true' if styles.size > 1

    super()
    @title = title
    @url = url
    @classnames = options[:classnames]
    @target = options.fetch(:target, '_self')
  end

  private

  def base_classes
    'inline-flex items-center rounded-lg px-3 min-h-8 min-w-8 ' \
      'hover:outline hover:outline-offset-1 hover:outline-neutral-700 hover:dark:outline-neutral-200'
  end

  def current_classes
    return '' unless @current

    'underline underline-offset-2'
  end

  def contained_classes
    return '' unless @contained

    'bg-pink-600/85 text-white dark:bg-pink-600/65 dark:text-white'
  end

  def ghost_classes
    return '' unless @ghost

    'outline outline-gray-400 dark:outline-gray-500 ' \
      'focus-visible:outline-neutral-700 dark:focus-visible:outline-neutral-200'
  end

  def large_classes
    return '' unless @large

    'px-6 py-2.5'
  end
end
