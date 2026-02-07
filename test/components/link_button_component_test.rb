require 'test_helper'

class LinkButtonComponentTest < ViewComponent::TestCase
  def setup
    @title = 'Explore'
    @url = '/explore'
    @target = '_self'
    @current = false
    @ghost = false
    @large = false
  end

  def test_renders_anchor_with_visible_title
    component = LinkButtonComponent.new(title: @title, url: @url, target: @target, current: @current, ghost: @ghost,
                                        large: @large)
    render_inline(component)

    assert_selector 'a', text: @title
    assert_selector "a[href='#{@url}']", text: @title
  end

  def test_adds_aria_current_page_when_current_true
    component = LinkButtonComponent.new(title: @title, url: @url, target: @target, current: true, ghost: @ghost,
                                        large: @large)
    render_inline(component)

    assert_selector "a[aria-current='page']"
  end

  def test_includes_hover_outline_classes_when_inactive
    component = LinkButtonComponent.new(title: @title, url: @url, target: @target, current: @current, ghost: @ghost,
                                        large: @large)
    rendered = render_inline(component)
    html = rendered.to_html

    assert_includes html, 'hover:outline'
  end

  def test_includes_min_touch_target_size_classes
    component = LinkButtonComponent.new(title: @title, url: @url, target: @target, current: @current, ghost: @ghost,
                                        large: @large)
    rendered = render_inline(component)
    html = rendered.to_html

    assert_includes html, 'min-h-8'
    assert_includes html, 'min-w-8'
  end

  def test_adds_rel_noopener_noreferrer_when_target_blank
    component = LinkButtonComponent.new(title: @title, url: @url, target: '_blank', current: @current, ghost: @ghost,
                                        large: @large)
    render_inline(component)

    assert_selector "a[target='_blank'][rel~='noopener'][rel~='noreferrer']"
  end

  def test_includes_sr_only_text_for_screen_readers_when_target_blank
    component = LinkButtonComponent.new(title: @title, url: @url, target: '_blank', current: @current, ghost: @ghost,
                                        large: @large)
    render_inline(component)

    assert_selector 'span.sr-only', text: I18n.t('opens_in_new_tab')
  end

  def test_includes_ghost_outline_classes_when_ghost_true
    component = LinkButtonComponent.new(title: @title, url: @url, target: @target, current: @current, ghost: true,
                                        large: @large)
    rendered = render_inline(component)
    html = rendered.to_html

    assert_includes html, 'outline-gray-400'
    assert_includes html, 'dark:outline-gray-500'
    assert_includes html, 'focus-visible:outline-neutral-700'
    assert_includes html, 'dark:focus-visible:outline-neutral-200'
  end

  def test_raises_argument_error_when_ghost_and_current_both_true
    error = assert_raises(ArgumentError) do
      LinkButtonComponent.new(title: @title, url: @url, ghost: true, current: true)
    end
    assert_equal 'only one of ghost, contained, current can be true', error.message
  end

  def test_raises_argument_error_when_ghost_and_contained_both_true
    error = assert_raises(ArgumentError) do
      LinkButtonComponent.new(title: @title, url: @url, ghost: true, contained: true)
    end
    assert_equal 'only one of ghost, contained, current can be true', error.message
  end

  def test_raises_argument_error_when_current_and_contained_both_true
    error = assert_raises(ArgumentError) do
      LinkButtonComponent.new(title: @title, url: @url, current: true, contained: true)
    end
    assert_equal 'only one of ghost, contained, current can be true', error.message
  end

  def test_raises_argument_error_when_ghost_contained_and_current_all_true
    error = assert_raises(ArgumentError) do
      LinkButtonComponent.new(title: @title, url: @url, ghost: true, contained: true, current: true)
    end
    assert_equal 'only one of ghost, contained, current can be true', error.message
  end

  def test_includes_large_size_classes_when_large_true
    component = LinkButtonComponent.new(title: @title, url: @url, target: @target, current: @current, ghost: @ghost,
                                        large: true)
    rendered = render_inline(component)
    html = rendered.to_html

    assert_includes html, 'px-6'
    assert_includes html, 'py-2.5'
  end

  def test_renders_icon_before_title_with_icon_before_slot
    component = LinkButtonComponent.new(title: @title, url: @url, target: @target, current: @current, ghost: @ghost,
                                        large: @large)
    rendered = render_inline(component) do |c|
      c.with_icon_before { '<svg class="test-icon-before"></svg>'.html_safe }
    end

    html = rendered.to_html
    assert_includes html, 'test-icon-before'
    assert_selector '.flex.items-center.gap-2'
  end

  def test_renders_icon_after_title_with_icon_after_slot
    component = LinkButtonComponent.new(title: @title, url: @url, target: @target, current: @current, ghost: @ghost,
                                        large: @large)
    rendered = render_inline(component) do |c|
      c.with_icon_after { '<svg class="test-icon-after"></svg>'.html_safe }
    end

    html = rendered.to_html
    assert_includes html, 'test-icon-after'
  end

  def test_renders_both_icons_in_correct_order_with_both_icon_slots
    component = LinkButtonComponent.new(title: @title, url: @url, target: @target, current: @current, ghost: @ghost,
                                        large: @large)
    rendered = render_inline(component) do |c|
      c.with_icon_before { '<svg class="icon-before"></svg>'.html_safe }
      c.with_icon_after { '<svg class="icon-after"></svg>'.html_safe }
    end

    content = rendered.to_html
    assert content.index('icon-before') < content.index(@title)
    assert content.index(@title) < content.index('icon-after')
  end

  def test_includes_current_underline_classes_when_current_true
    component = LinkButtonComponent.new(title: @title, url: @url, target: @target, current: true, ghost: @ghost,
                                        large: @large)
    rendered = render_inline(component)
    html = rendered.to_html

    assert_includes html, 'underline'
    assert_includes html, 'underline-offset-2'
  end

  def test_includes_contained_background_classes_when_contained_true
    component = LinkButtonComponent.new(title: @title, url: @url, target: @target, current: @current, contained: true,
                                        large: @large)
    rendered = render_inline(component)
    html = rendered.to_html

    assert_includes html, 'bg-pink-600/85'
    assert_includes html, 'text-white'
    assert_includes html, 'dark:bg-pink-600/65'
    assert_includes html, 'dark:text-white'
  end

  def test_does_not_include_current_classes_when_current_false
    component = LinkButtonComponent.new(title: @title, url: @url, target: @target, current: false, ghost: @ghost,
                                        large: @large)
    rendered = render_inline(component)
    html = rendered.to_html

    assert_not_includes html, 'underline-offset-2'
  end

  def test_does_not_include_contained_classes_when_contained_false
    component = LinkButtonComponent.new(title: @title, url: @url, target: @target, current: @current, contained: false,
                                        large: @large)
    rendered = render_inline(component)
    html = rendered.to_html

    assert_not_includes html, 'bg-pink-600/85'
  end

  def test_does_not_include_ghost_classes_when_ghost_false
    component = LinkButtonComponent.new(title: @title, url: @url, target: @target, current: @current, ghost: false,
                                        large: @large)
    rendered = render_inline(component)
    html = rendered.to_html

    assert_not_includes html, 'outline-gray-400'
  end

  def test_does_not_include_large_classes_when_large_false
    component = LinkButtonComponent.new(title: @title, url: @url, target: @target, current: @current, ghost: @ghost,
                                        large: false)
    rendered = render_inline(component)
    html = rendered.to_html

    assert_not_includes html, 'px-6'
    assert_not_includes html, 'py-2.5'
  end

  def test_does_not_add_rel_when_target_self
    component = LinkButtonComponent.new(title: @title, url: @url, target: '_self', current: @current, ghost: @ghost,
                                        large: @large)
    render_inline(component)

    assert_selector "a[target='_self']"
    assert_no_selector 'a[rel]'
  end

  def test_does_not_add_aria_current_when_current_false
    component = LinkButtonComponent.new(title: @title, url: @url, target: @target, current: false, ghost: @ghost,
                                        large: @large)
    render_inline(component)

    assert_no_selector 'a[aria-current]'
  end

  def test_does_not_include_sr_only_text_when_target_self
    component = LinkButtonComponent.new(title: @title, url: @url, target: '_self', current: @current, ghost: @ghost,
                                        large: @large)
    render_inline(component)

    assert_no_selector 'span.sr-only'
  end

  def test_applies_custom_classnames
    component = LinkButtonComponent.new(title: @title, url: @url, classnames: 'custom-class another-class')
    rendered = render_inline(component)
    html = rendered.to_html

    assert_includes html, 'custom-class'
    assert_includes html, 'another-class'
  end

  def test_includes_base_classes_for_all_variations
    component = LinkButtonComponent.new(title: @title, url: @url)
    rendered = render_inline(component)
    html = rendered.to_html

    assert_includes html, 'inline-flex'
    assert_includes html, 'items-center'
    assert_includes html, 'rounded-lg'
    assert_includes html, 'px-3'
  end
end
