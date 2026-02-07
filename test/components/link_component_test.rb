require 'test_helper'

class LinkComponentTest < ViewComponent::TestCase
  def setup
    @title = 'About'
    @url = '/about'
    @target = '_self'
    @current = false
    @classnames = nil
  end

  def test_renders_anchor_with_visible_title
    component = LinkComponent.new(title: @title, url: @url, target: @target, current: @current, classnames: @classnames)
    render_inline(component)

    assert_selector 'a', text: @title
    assert_selector "a[href='#{@url}']", text: @title
  end

  def test_includes_correct_base_classes
    component = LinkComponent.new(title: @title, url: @url, target: @target, current: @current, classnames: @classnames)
    rendered = render_inline(component)

    assert_includes rendered.to_html, 'hover:underline py-1 px-2'
  end

  def test_adds_aria_current_page_when_current_true
    component = LinkComponent.new(title: @title, url: @url, target: @target, current: true, classnames: @classnames)
    render_inline(component)

    assert_selector "a[aria-current='page']"
  end

  def test_includes_underline_classes_when_current_true
    component = LinkComponent.new(title: @title, url: @url, target: @target, current: true, classnames: @classnames)
    rendered = render_inline(component)
    html = rendered.to_html

    assert_includes html, 'underline'
    assert_includes html, 'underline-offset-2'
  end

  def test_does_not_add_aria_current_when_current_false
    component = LinkComponent.new(title: @title, url: @url, target: @target, current: false, classnames: @classnames)
    render_inline(component)

    assert_no_selector 'a[aria-current]'
  end

  def test_does_not_add_rel_attribute_when_target_self
    component = LinkComponent.new(title: @title, url: @url, target: '_self', current: @current, classnames: @classnames)
    render_inline(component)

    assert_no_selector 'a[rel]'
  end

  def test_does_not_include_sr_only_text_when_target_self
    component = LinkComponent.new(title: @title, url: @url, target: '_self', current: @current, classnames: @classnames)
    render_inline(component)

    assert_no_selector 'span.sr-only'
  end

  def test_adds_rel_noopener_noreferrer_when_target_blank
    component = LinkComponent.new(title: @title, url: @url, target: '_blank', current: @current,
                                  classnames: @classnames)
    render_inline(component)

    assert_selector "a[target='_blank'][rel~='noopener'][rel~='noreferrer']"
  end

  def test_includes_sr_only_text_for_screen_readers_when_target_blank
    component = LinkComponent.new(title: @title, url: @url, target: '_blank', current: @current,
                                  classnames: @classnames)
    render_inline(component)

    assert_selector 'span.sr-only', text: I18n.t('opens_in_new_tab')
  end

  def test_applies_custom_classes_with_custom_classnames
    component = LinkComponent.new(title: @title, url: @url, target: @target, current: @current,
                                  classnames: 'text-lg font-bold')
    rendered = render_inline(component)
    html = rendered.to_html

    assert_includes html, 'text-lg'
    assert_includes html, 'font-bold'
  end
end
