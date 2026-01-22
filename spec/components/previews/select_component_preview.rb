class SelectComponentPreview < ViewComponent::Preview
  # @label Default
  def default
    render(SelectComponent.new(
             name: :country,
             options: [['Select a country', ''], ['United States', 'us'], ['Canada', 'ca'], ['Mexico', 'mx']]
           ))
  end

  # @label With Selected Value
  def with_selected
    render(SelectComponent.new(
             name: :country,
             options: [['Select a country', ''], ['United States', 'us'], ['Canada', 'ca'], ['Mexico', 'mx']],
             selected: 'ca'
           ))
  end

  # @label Large
  def large
    render(SelectComponent.new(
             name: :country,
             options: [['Select a country', ''], ['United States', 'us'], ['Canada', 'ca'], ['Mexico', 'mx']],
             large: true
           ))
  end

  # @label Disabled
  def disabled
    render(SelectComponent.new(
             name: :state,
             options: [['No states available', '']],
             disabled: true
           ))
  end

  # @label Large and Disabled
  def large_disabled
    render(SelectComponent.new(
             name: :state,
             options: [['No states available', '']],
             large: true,
             disabled: true
           ))
  end

  # @label Required
  def required
    render(SelectComponent.new(
             name: :country,
             options: [['Select a country', ''], ['United States', 'us'], ['Canada', 'ca'], ['Mexico', 'mx']],
             required: true
           ))
  end

  # @label With ARIA Label
  def with_aria_label
    render(SelectComponent.new(
             name: :country,
             options: [['United States', 'us'], ['Canada', 'ca'], ['Mexico', 'mx']],
             aria_label: 'Select your country of residence'
           ))
  end

  # @label With Help Text (aria-describedby)
  def with_help_text
    render_with_template
  end

  # @label Error State
  def error_state
    render(SelectComponent.new(
             name: :country,
             options: [['Select a country', ''], ['United States', 'us'], ['Canada', 'ca'], ['Mexico', 'mx']],
             aria_invalid: true,
             aria_describedby: 'country-error'
           ))
  end
end
