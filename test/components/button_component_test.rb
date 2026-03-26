require 'test_helper'

class ButtonComponentTest < ViewComponent::TestCase
  def setup
    @title = 'Submit'
    @type = :submit
    @form = nil
    @ghost = false
  end

  def test_renders_button_tag_with_title_without_form
    component = ButtonComponent.new(title: @title, type: @type, form: @form, ghost: @ghost)
    render_inline(component)

    assert_selector 'button[type="submit"]', text: @title
  end

  def test_uses_form_button_with_form
    form = FormBuilderDouble.new
    form.expect(:button, '<button type="submit">Submit</button>'.html_safe) do |title, **opts|
      title == @title && opts[:type] == @type
    end

    component = ButtonComponent.new(title: @title, type: @type, form: form, ghost: @ghost)
    render_inline(component)

    assert_predicate form, :verified?
  end

  def test_includes_base_hover_outline_classes
    component = ButtonComponent.new(title: @title, type: @type, form: @form, ghost: @ghost)
    rendered = render_inline(component)
    html = rendered.to_html

    assert_includes html, 'hover:outline'
  end

  def test_includes_focus_visible_outline_classes
    component = ButtonComponent.new(title: @title, type: @type, form: @form, ghost: @ghost)
    rendered = render_inline(component)
    html = rendered.to_html

    assert_includes html, 'focus-visible:outline-neutral-700'
    assert_includes html, 'focus-visible:dark:outline-neutral-200'
  end

  def test_includes_min_touch_target_size_classes
    component = ButtonComponent.new(title: @title, type: @type, form: @form, ghost: @ghost)
    rendered = render_inline(component)
    html = rendered.to_html

    assert_includes html, 'min-h-8'
    assert_includes html, 'min-w-8'
  end

  def test_includes_pink_background_classes_with_default_styling
    component = ButtonComponent.new(title: @title, type: @type, form: @form, ghost: @ghost)
    rendered = render_inline(component)
    html = rendered.to_html

    assert_includes html, 'bg-pink-600/85'
    assert_includes html, 'text-white'
    assert_includes html, 'dark:bg-pink-600/65'
  end

  def test_does_not_include_ghost_outline_classes_with_default_styling
    component = ButtonComponent.new(title: @title, type: @type, form: @form, ghost: @ghost)
    rendered = render_inline(component)
    html = rendered.to_html

    assert_not_includes html, 'outline-gray-400'
  end

  def test_includes_ghost_outline_classes_when_ghost_true
    component = ButtonComponent.new(title: @title, type: @type, form: @form, ghost: true)
    rendered = render_inline(component)
    html = rendered.to_html

    assert_includes html, 'outline-gray-400'
    assert_includes html, 'dark:outline-gray-500'
  end

  def test_does_not_include_pink_background_classes_when_ghost_true
    component = ButtonComponent.new(title: @title, type: @type, form: @form, ghost: true)
    rendered = render_inline(component)
    html = rendered.to_html

    assert_not_includes html, 'bg-pink-600/85'
  end

  def test_includes_large_size_classes_when_large_true
    component = ButtonComponent.new(title: @title, type: @type, large: true)
    rendered = render_inline(component)
    html = rendered.to_html

    assert_includes html, 'px-6'
    assert_includes html, 'py-2.5'
  end
end
