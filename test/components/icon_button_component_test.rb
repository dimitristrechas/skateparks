require 'test_helper'

class IconButtonComponentTest < ViewComponent::TestCase
  def setup
    @aria_label = 'Toggle theme'
    @html_options = {}
    @icon_svg = '<svg class="test-icon" aria-hidden="true"></svg>'.html_safe
  end

  def test_renders_button_with_aria_label
    component = IconButtonComponent.new(aria_label: @aria_label, **@html_options)
    render_inline(component) { |c| c.with_icon { @icon_svg } }

    assert_selector "button[aria-label='#{@aria_label}']"
  end

  def test_renders_button_with_type_button_by_default
    component = IconButtonComponent.new(aria_label: @aria_label, **@html_options)
    render_inline(component) { |c| c.with_icon { @icon_svg } }

    assert_selector 'button[type="button"]'
  end

  def test_renders_icon_slot_content
    component = IconButtonComponent.new(aria_label: @aria_label, **@html_options)
    render_inline(component) { |c| c.with_icon { @icon_svg } }

    assert_selector 'svg.test-icon'
  end

  def test_includes_base_styling_classes
    component = IconButtonComponent.new(aria_label: @aria_label, **@html_options)
    rendered = render_inline(component) { |c| c.with_icon { @icon_svg } }
    html = rendered.to_html

    assert_includes html, 'rounded-lg'
    assert_includes html, 'p-1.5'
    assert_includes html, 'cursor-pointer'
  end

  def test_includes_min_touch_target_size_classes
    component = IconButtonComponent.new(aria_label: @aria_label, **@html_options)
    rendered = render_inline(component) { |c| c.with_icon { @icon_svg } }
    html = rendered.to_html

    assert_includes html, 'min-h-8'
    assert_includes html, 'min-w-8'
  end

  def test_includes_hover_outline_classes
    component = IconButtonComponent.new(aria_label: @aria_label, **@html_options)
    rendered = render_inline(component) { |c| c.with_icon { @icon_svg } }
    html = rendered.to_html

    assert_includes html, 'hover:outline'
    assert_includes html, 'hover:outline-offset-1'
    assert_includes html, 'hover:outline-neutral-700'
    assert_includes html, 'dark:hover:outline-neutral-200'
  end

  def test_includes_focus_visible_outline_classes
    component = IconButtonComponent.new(aria_label: @aria_label, **@html_options)
    rendered = render_inline(component) { |c| c.with_icon { @icon_svg } }
    html = rendered.to_html

    assert_includes html, 'focus-visible:outline'
    assert_includes html, 'focus-visible:outline-offset-1'
    assert_includes html, 'focus-visible:outline-neutral-700'
    assert_includes html, 'dark:focus-visible:outline-neutral-200'
  end

  def test_passes_through_id_attribute_with_custom_id
    component = IconButtonComponent.new(aria_label: @aria_label, id: 'theme-toggle')
    render_inline(component) { |c| c.with_icon { @icon_svg } }

    assert_selector 'button#theme-toggle'
  end

  def test_passes_through_data_action_attribute_with_data_attributes
    component = IconButtonComponent.new(aria_label: @aria_label, data: { action: 'click->header#toggleThemeMode' })
    render_inline(component) { |c| c.with_icon { @icon_svg } }

    assert_selector "button[data-action='click->header#toggleThemeMode']"
  end

  def test_allows_overriding_type_with_custom_type
    component = IconButtonComponent.new(aria_label: @aria_label, type: 'submit')
    render_inline(component) { |c| c.with_icon { @icon_svg } }

    assert_selector 'button[type="submit"]'
  end

  def test_merges_custom_classes_with_base_classes_with_additional_classes
    component = IconButtonComponent.new(aria_label: @aria_label, class: 'custom-class')
    rendered = render_inline(component) { |c| c.with_icon { @icon_svg } }
    html = rendered.to_html

    assert_includes html, 'rounded-lg'
    assert_includes html, 'custom-class'
  end

  def test_requires_aria_label
    error = assert_raises(ArgumentError) do
      IconButtonComponent.new
    end
    assert_match(/aria_label/, error.message)
  end

  def test_requires_icon_slot
    component = IconButtonComponent.new(aria_label: @aria_label)
    error = assert_raises(ArgumentError) do
      render_inline(component)
    end
    assert_match(/icon slot is required/, error.message)
  end
end
