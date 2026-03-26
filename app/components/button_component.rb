class ButtonComponent < ViewComponent::Base
  def initialize(title:, type:, form: nil, ghost: false, large: false)
    super()
    @title = title
    @form = form
    @type = type
    @ghost = ghost
    @large = large
  end

  private

  def base_classes
    'inline-flex items-center rounded-lg px-3 min-h-8 min-w-8 ' \
      'hover:outline hover:outline-offset-1 hover:outline-neutral-700 hover:dark:outline-neutral-200 ' \
      'focus-visible:outline focus-visible:outline-offset-1 focus-visible:outline-neutral-700 ' \
      'focus-visible:dark:outline-neutral-200 cursor-pointer'
  end

  def default_classes
    return '' if @ghost

    'bg-pink-600/85 text-white dark:bg-pink-600/65 dark:text-white'
  end

  def ghost_classes
    return '' unless @ghost

    'outline outline-gray-400 dark:outline-gray-500'
  end

  def large_classes
    return '' unless @large

    'px-6 py-2.5'
  end

  def button_classes
    class_names(base_classes, default_classes, ghost_classes, large_classes)
  end
end
