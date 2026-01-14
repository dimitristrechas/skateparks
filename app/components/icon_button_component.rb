class IconButtonComponent < ViewComponent::Base
  renders_one :icon

  def initialize(aria_label:, **html_options)
    super
    @aria_label = aria_label
    @html_options = html_options
  end

  def before_render
    raise ArgumentError, 'icon slot is required' unless icon?
  end

  private

  def base_classes
    'inline-flex items-center justify-center rounded-lg p-1.5 min-h-8 min-w-8 ' \
      'text-gray-500 dark:text-gray-400 cursor-pointer ' \
      'hover:outline hover:outline-offset-1 hover:outline-neutral-700 dark:hover:outline-neutral-200 ' \
      'focus-visible:outline focus-visible:outline-offset-1 focus-visible:outline-neutral-700 ' \
      'dark:focus-visible:outline-neutral-200'
  end

  def merged_html_options
    @html_options.merge(
      type: @html_options.fetch(:type, 'button'),
      'aria-label': @aria_label,
      class: class_names(base_classes, @html_options[:class])
    )
  end
end
