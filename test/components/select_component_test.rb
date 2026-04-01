require 'test_helper'

class SelectComponentTest < ViewComponent::TestCase
  def setup
    @name = :country
    @options = [['All', ''], ['USA', 'us'], ['Canada', 'ca']]
    @selected = nil
    @disabled = false
    @large = false
  end

  def test_renders_select_with_correct_name
    component = SelectComponent.new(name: @name, options: @options, selected: @selected, disabled: @disabled,
                                    large: @large)
    render_inline(component)

    assert_selector 'select[name="country"]'
  end

  def test_renders_all_options
    component = SelectComponent.new(name: @name, options: @options, selected: @selected, disabled: @disabled,
                                    large: @large)
    render_inline(component)

    assert_selector 'option', text: 'All'
    assert_selector 'option', text: 'USA'
    assert_selector 'option', text: 'Canada'
  end

  def test_includes_neutral_background_classes
    component = SelectComponent.new(name: @name, options: @options, selected: @selected, disabled: @disabled,
                                    large: @large)
    rendered = render_inline(component)
    html = rendered.to_html

    assert_includes html, 'bg-white'
    assert_includes html, 'dark:bg-neutral-700'
  end

  def test_includes_neutral_border_classes
    component = SelectComponent.new(name: @name, options: @options, selected: @selected, disabled: @disabled,
                                    large: @large)
    rendered = render_inline(component)
    html = rendered.to_html

    assert_includes html, 'border-neutral-300'
    assert_includes html, 'dark:border-neutral-600'
  end

  def test_includes_focus_visible_outline_classes
    component = SelectComponent.new(name: @name, options: @options, selected: @selected, disabled: @disabled,
                                    large: @large)
    rendered = render_inline(component)
    html = rendered.to_html

    assert_includes html, 'focus-visible:outline'
    assert_includes html, 'focus-visible:outline-offset-1'
    assert_includes html, 'focus-visible:outline-neutral-700'
  end

  def test_includes_hover_outline_classes
    component = SelectComponent.new(name: @name, options: @options, selected: @selected, disabled: @disabled,
                                    large: @large)
    rendered = render_inline(component)
    html = rendered.to_html

    assert_includes html, 'hover:outline'
    assert_includes html, 'hover:outline-neutral-700'
    assert_includes html, 'dark:hover:outline-neutral-200'
  end

  def test_marks_correct_option_as_selected_with_selected_value
    component = SelectComponent.new(name: @name, options: @options, selected: 'us', disabled: @disabled, large: @large)
    render_inline(component)

    assert_selector 'option[selected][value="us"]'
  end

  def test_renders_disabled_select_when_disabled
    component = SelectComponent.new(name: @name, options: @options, selected: @selected, disabled: true, large: @large)
    render_inline(component)

    assert_selector 'select[disabled]'
  end

  def test_includes_disabled_styling_classes_when_disabled
    component = SelectComponent.new(name: @name, options: @options, selected: @selected, disabled: true, large: @large)
    rendered = render_inline(component)
    html = rendered.to_html

    assert_includes html, 'disabled:opacity-50'
    assert_includes html, 'disabled:cursor-not-allowed'
  end

  def test_includes_large_size_classes_when_large
    component = SelectComponent.new(name: @name, options: @options, selected: @selected, disabled: @disabled,
                                    large: true)
    rendered = render_inline(component)
    html = rendered.to_html

    assert_includes html, 'px-6'
    assert_includes html, 'py-2.5'
  end

  def test_passes_data_attributes_to_select_with_custom_html_options
    component = SelectComponent.new(
      name: @name,
      options: @options,
      data: { 'controller-target': 'select' }
    )
    render_inline(component)

    assert_selector 'select[data-controller-target="select"]'
  end

  def test_renders_select_with_custom_id
    component = SelectComponent.new(name: @name, options: @options, id: 'custom-select')
    render_inline(component)

    assert_selector 'select#custom-select'
  end

  def test_renders_required_attribute_when_required
    component = SelectComponent.new(name: @name, options: @options, required: true)
    render_inline(component)

    assert_selector 'select[required]'
  end

  def test_auto_sets_aria_required_when_required
    component = SelectComponent.new(name: @name, options: @options, required: true)
    render_inline(component)

    assert_selector 'select[aria-required="true"]'
  end

  def test_renders_aria_label_attribute_with_aria_label
    component = SelectComponent.new(name: @name, options: @options, aria: { label: 'Select your country' })
    render_inline(component)

    assert_selector 'select[aria-label="Select your country"]'
  end

  def test_renders_aria_describedby_attribute_with_aria_describedby
    component = SelectComponent.new(name: @name, options: @options, aria: { describedby: 'country-help' })
    render_inline(component)

    assert_selector 'select[aria-describedby="country-help"]'
  end

  def test_renders_aria_required_attribute_with_explicit_aria_required
    component = SelectComponent.new(name: @name, options: @options, aria: { required: true })
    render_inline(component)

    assert_selector 'select[aria-required="true"]'
  end

  def test_renders_aria_invalid_attribute_with_aria_invalid
    component = SelectComponent.new(name: @name, options: @options, aria: { invalid: true })
    render_inline(component)

    assert_selector 'select[aria-invalid="true"]'
  end

  def test_auto_generates_id_from_name_when_no_id_given
    component = SelectComponent.new(name: @name, options: @options)
    render_inline(component)

    assert_selector 'select[name="country"][id]'
    assert_no_selector 'select[id="custom-select"]'
  end
end
