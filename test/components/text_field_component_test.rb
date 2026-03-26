require 'test_helper'

class TextFieldComponentTest < ViewComponent::TestCase
  def setup
    @form = FormBuilderDouble.new
    @name = :email
    @title = 'Email Address'
    @classnames = nil
  end

  def test_renders_label_with_title
    @form.expect(:label, '<label>Email Address</label>'.html_safe) do |name, title, **_opts|
      name == @name && title == @title
    end
    @form.expect(:text_field, '<input type="text">'.html_safe) { |name, **_opts| name == @name }

    component = TextFieldComponent.new(form: @form, name: @name, title: @title, classnames: @classnames)
    render_inline(component)

    assert_predicate @form, :verified?
  end

  def test_renders_text_field_with_name
    @form.expect(:label, '<label>Email Address</label>'.html_safe) { |_name, _title, **_opts| true }
    @form.expect(:text_field, '<input type="text" name="email">'.html_safe) do |name, **_opts|
      name == @name
    end

    component = TextFieldComponent.new(form: @form, name: @name, title: @title, classnames: @classnames)
    render_inline(component)

    assert_predicate @form, :verified?
  end

  def test_applies_label_classes
    expected_label = '<label class="block text-neutral-600 dark:text-neutral-300 mb-1">Email</label>'.html_safe
    @form.expect(:label, expected_label) do |_name, _title, **opts|
      opts[:class] == 'block text-neutral-600 dark:text-neutral-300 mb-1'
    end
    @form.expect(:text_field, '<input type="text">'.html_safe) { |_name, **_opts| true }

    component = TextFieldComponent.new(form: @form, name: @name, title: @title, classnames: @classnames)
    render_inline(component)

    assert_predicate @form, :verified?
  end

  def test_applies_text_field_classes
    @form.expect(:label, '<label>Email</label>'.html_safe) { |_name, _title, **_opts| true }
    @form.expect(:text_field,
                 '<input type="text" class="text-neutral-600 w-1/2 p-1 rounded">'.html_safe) do |_name, **opts|
      opts[:class] == 'text-neutral-600 w-1/2 p-1 rounded'
    end

    component = TextFieldComponent.new(form: @form, name: @name, title: @title, classnames: @classnames)
    render_inline(component)

    assert_predicate @form, :verified?
  end

  def test_applies_custom_classnames_to_wrapper
    @form.expect(:label, '<label>Email</label>'.html_safe) { |_name, _title, **_opts| true }
    @form.expect(:text_field, '<input type="text">'.html_safe) { |_name, **_opts| true }

    component = TextFieldComponent.new(form: @form, name: @name, title: @title, classnames: 'mt-4 custom-class')
    rendered = render_inline(component)
    html = rendered.to_html

    assert_includes html, 'mt-4'
    assert_includes html, 'custom-class'
  end

  def test_wrapper_div_present
    @form.expect(:label, '<label>Email</label>'.html_safe) { |_name, _title, **_opts| true }
    @form.expect(:text_field, '<input type="text">'.html_safe) { |_name, **_opts| true }

    component = TextFieldComponent.new(form: @form, name: @name, title: @title, classnames: @classnames)
    render_inline(component)

    assert_selector 'div'
  end

  def test_handles_nil_classnames
    @form.expect(:label, '<label>Email</label>'.html_safe) { |_name, _title, **_opts| true }
    @form.expect(:text_field, '<input type="text">'.html_safe) { |_name, **_opts| true }

    component = TextFieldComponent.new(form: @form, name: @name, title: @title, classnames: nil)
    render_inline(component)

    assert_selector 'div'
  end
end
