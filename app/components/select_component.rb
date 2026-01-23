class SelectComponent < ViewComponent::Base
  # rubocop:disable Metrics/ParameterLists
  def initialize(name:, options:, selected: nil, disabled: false, large: false,
                 id: nil, required: false, aria_label: nil, aria_describedby: nil,
                 aria_required: nil, aria_invalid: nil, **html_options)
    super
    @name = name
    @options = options
    @selected = selected
    @disabled = disabled
    @large = large
    @id = id
    @required = required
    @aria_label = aria_label
    @aria_describedby = aria_describedby
    @aria_required = aria_required
    @aria_invalid = aria_invalid
    @html_options = html_options
  end
  # rubocop:enable Metrics/ParameterLists

  private

  def base_classes
    'w-full md:w-56 rounded-lg border block shadow-none focus:shadow-none focus:ring-0 ' \
      'bg-white border-neutral-300 ' \
      'dark:bg-neutral-700 dark:border-neutral-600 ' \
      'focus-visible:outline focus-visible:outline-offset-1 focus-visible:outline-neutral-700 ' \
      'dark:focus-visible:outline-neutral-200 ' \
      'hover:outline hover:outline-offset-1 hover:outline-neutral-700 ' \
      'dark:hover:outline-neutral-200 ' \
      'disabled:opacity-50 disabled:cursor-not-allowed'
  end

  def size_classes
    @large ? 'px-6 py-2.5' : 'p-2.5'
  end

  def select_classes
    class_names(base_classes, size_classes)
  end

  def aria_attributes
    {}.tap do |attrs|
      attrs['aria-label'] = @aria_label if @aria_label
      attrs['aria-describedby'] = @aria_describedby if @aria_describedby
      attrs['aria-invalid'] = @aria_invalid.to_s if @aria_invalid
      aria_req = @aria_required.nil? ? @required : @aria_required
      attrs['aria-required'] = aria_req.to_s if aria_req
    end
  end
end
