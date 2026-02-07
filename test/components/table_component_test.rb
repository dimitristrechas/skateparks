# frozen_string_literal: true

require 'test_helper'

class TableComponentTest < ViewComponent::TestCase
  def test_renders_outer_wrapper_with_shadow_and_rounded_classes
    component = TableComponent.new
    rendered = render_inline(component) do |table|
      table.with_header do
        '<th>Name</th><th>Status</th>'.html_safe
      end
      table.with_row { '<td>Park 1</td><td>Active</td>'.html_safe }
      table.with_row { '<td>Park 2</td><td>Draft</td>'.html_safe }
    end

    html = rendered.to_html
    assert_includes html, 'shadow-md'
    assert_includes html, 'sm:rounded-lg'
  end

  def test_renders_table_element
    component = TableComponent.new
    render_inline(component) do |table|
      table.with_header do
        '<th>Name</th><th>Status</th>'.html_safe
      end
      table.with_row { '<td>Park 1</td><td>Active</td>'.html_safe }
      table.with_row { '<td>Park 2</td><td>Draft</td>'.html_safe }
    end

    assert_selector 'table'
  end

  def test_renders_header_inside_thead
    component = TableComponent.new
    render_inline(component) do |table|
      table.with_header do
        '<th>Name</th><th>Status</th>'.html_safe
      end
      table.with_row { '<td>Park 1</td><td>Active</td>'.html_safe }
      table.with_row { '<td>Park 2</td><td>Draft</td>'.html_safe }
    end

    assert_selector 'thead th', text: 'Name'
    assert_selector 'thead th', text: 'Status'
  end

  def test_renders_rows_inside_tbody
    component = TableComponent.new
    render_inline(component) do |table|
      table.with_header do
        '<th>Name</th><th>Status</th>'.html_safe
      end
      table.with_row { '<td>Park 1</td><td>Active</td>'.html_safe }
      table.with_row { '<td>Park 2</td><td>Draft</td>'.html_safe }
    end

    assert_selector 'tbody tr', count: 2
    assert_selector 'tbody td', text: 'Park 1'
    assert_selector 'tbody td', text: 'Park 2'
  end

  def test_applies_alternating_row_styles
    component = TableComponent.new
    rendered = render_inline(component) do |table|
      table.with_header do
        '<th>Name</th><th>Status</th>'.html_safe
      end
      table.with_row { '<td>Park 1</td><td>Active</td>'.html_safe }
      table.with_row { '<td>Park 2</td><td>Draft</td>'.html_safe }
    end

    html = rendered.to_html
    assert_includes html, 'odd:bg-white'
    assert_includes html, 'even:bg-gray-50'
  end

  def test_renders_table_with_empty_tbody_when_header_only
    component = TableComponent.new
    render_inline(component) do |table|
      table.with_header do
        '<th>Name</th>'.html_safe
      end
    end

    assert_selector 'table'
    assert_selector 'thead th', text: 'Name'
    assert_selector 'tbody'
    assert_no_selector 'tbody tr'
  end
end
