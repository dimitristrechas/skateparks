require 'test_helper'

class SkateparkImageListItemComponentTest < ViewComponent::TestCase
  def test_renders_list_item_with_sortable_attributes
    render_inline(SkateparkImageListItemComponent.new(index: 0))

    assert_selector '[data-sortable-item][role="listitem"]'
  end

  def test_renders_drag_handle_with_indexed_aria_label
    render_inline(SkateparkImageListItemComponent.new(index: 2))

    assert_selector '[data-sort-handle][aria-label="Reorder image 3"]'
  end

  def test_renders_drag_handle_without_index_when_nil
    render_inline(SkateparkImageListItemComponent.new)

    assert_selector '[data-sort-handle][aria-label="Reorder image"]'
  end

  def test_renders_position_label_with_index
    render_inline(SkateparkImageListItemComponent.new(index: 4))

    assert_selector '[data-position-label]', text: '5'
  end

  def test_renders_empty_position_label_without_index
    render_inline(SkateparkImageListItemComponent.new)

    assert_selector '[data-position-label]', text: ''
  end

  def test_renders_move_up_button_with_indexed_aria_label
    render_inline(SkateparkImageListItemComponent.new(index: 1))

    assert_selector '[data-move-up-button][aria-label="Move image 2 up"]'
  end

  def test_renders_move_down_button_with_indexed_aria_label
    render_inline(SkateparkImageListItemComponent.new(index: 1))

    assert_selector '[data-move-down-button][aria-label="Move image 2 down"]'
  end

  def test_renders_delete_button_with_indexed_aria_label
    render_inline(SkateparkImageListItemComponent.new(index: 0))

    assert_selector '[data-delete-button][aria-label="Delete image 1"]'
  end

  def test_renders_move_buttons_without_index_when_nil
    render_inline(SkateparkImageListItemComponent.new)

    assert_selector '[data-move-up-button][aria-label="Move image up"]'
    assert_selector '[data-move-down-button][aria-label="Move image down"]'
    assert_selector '[data-delete-button][aria-label="Delete image"]'
  end

  def test_renders_hidden_class_when_destroyed
    rendered = render_inline(SkateparkImageListItemComponent.new(destroyed: true))

    assert_includes rendered.to_html, 'hidden'
    assert_selector '[data-destroyed="true"]'
  end

  def test_does_not_render_hidden_class_when_not_destroyed
    render_inline(SkateparkImageListItemComponent.new(destroyed: false))

    assert_no_selector '.hidden'
    assert_selector '[data-destroyed="false"]'
  end

  def test_renders_fields_slot
    render_inline(SkateparkImageListItemComponent.new) do |item|
      item.with_fields { '<input type="hidden" name="test" value="1">'.html_safe }
    end

    assert_selector 'input[name="test"][value="1"]', visible: :all
  end

  def test_renders_preview_slot
    render_inline(SkateparkImageListItemComponent.new) do |item|
      item.with_preview { '<img alt="test" class="test-preview">'.html_safe }
    end

    assert_selector 'img.test-preview'
  end

  def test_renders_subtitle_slot
    render_inline(SkateparkImageListItemComponent.new) do |item|
      item.with_subtitle { '<p class="test-subtitle">Info text</p>'.html_safe }
    end

    assert_selector 'p.test-subtitle', text: 'Info text'
  end

  def test_renders_stimulus_actions_on_buttons
    render_inline(SkateparkImageListItemComponent.new)

    assert_selector '[data-action="click->admin--skateparks--form#moveUp"]'
    assert_selector '[data-action="click->admin--skateparks--form#moveDown"]'
    assert_selector '[data-action="click->admin--skateparks--form#removeImage"]'
  end
end
