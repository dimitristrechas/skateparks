class SelectComponent < ViewComponent::Base
  # rubocop:disable-next Metrics/ParameterLists
  def initialize(name:, options:, selected: nil, disabled: false, large: false,
                 id: nil, required: false, aria: {}, **html_options)
    super()
    @name = name
    @options = options
    @selected = selected
    @disabled = disabled
    @large = large
    @id = id
    @required = required
    @aria = aria
    @html_options = html_options
  end

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

  def select_tag_options
    options = {
      disabled: @disabled,
      required: @required,
      class: select_classes,
    }.merge(aria_attributes).merge(@html_options)

    options[:id] = @id if @id.present?
    options
  end

  def aria_attributes
    {}.tap do |attrs|
      attrs['aria-label'] = @aria[:label] if @aria[:label]
      attrs['aria-describedby'] = @aria[:describedby] if @aria[:describedby]
      attrs['aria-invalid'] = @aria[:invalid].to_s if @aria[:invalid]
      aria_req = @aria[:required].nil? ? @required : @aria[:required]
      attrs['aria-required'] = aria_req.to_s if aria_req
    end
  end
end
