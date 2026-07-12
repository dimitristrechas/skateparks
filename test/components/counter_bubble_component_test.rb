# frozen_string_literal: true

require 'test_helper'

class CounterBubbleComponentTest < ViewComponent::TestCase
  def test_renders_count
    component = CounterBubbleComponent.new(count: 5, label: '5 pending video suggestions')
    render_inline(component)

    assert_selector 'span', text: '5'
  end

  def test_renders_zero_count
    component = CounterBubbleComponent.new(count: 0, label: '0 pending video suggestions')
    render_inline(component)

    assert_selector 'span', text: '0'
  end

  def test_includes_aria_label
    component = CounterBubbleComponent.new(count: 3, label: '3 visible site announcements')
    rendered = render_inline(component)

    assert_includes rendered.to_html, 'aria-label="3 visible site announcements"'
  end

  def test_includes_bubble_classes
    component = CounterBubbleComponent.new(count: 1, label: '1 pending video suggestion')
    rendered = render_inline(component)
    html = rendered.to_html

    assert_includes html, 'rounded-full'
    assert_includes html, 'bg-pink-600/85'
    assert_includes html, 'tabular-nums'
  end
end
