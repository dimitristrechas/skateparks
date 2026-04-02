require 'test_helper'

module Admin
  class SortableListItemComponentTest < ViewComponent::TestCase
    def test_renders_image_item_with_sortable_attributes
      render_inline(Admin::SortableListItemComponent.new(resource_type: :image, index: 0))

      assert_selector '[data-sortable-item][data-resource-type="image"][role="listitem"]'
      assert_selector '[data-position-label]', text: '1'
    end

    def test_renders_image_labels_and_actions
      render_inline(Admin::SortableListItemComponent.new(resource_type: :image, index: 2))

      assert_selector '[data-sort-handle][aria-label="Reorder image 3"]'
      assert_selector '[data-move-up-button][aria-label="Move image 3 up"]'
      assert_selector '[data-move-down-button][aria-label="Move image 3 down"]'
      assert_selector '[data-delete-button][aria-label="Delete image 3"]'
      assert_selector '[data-delete-button][data-action="click->admin--skateparks--form#removeImage"]'
    end

    def test_renders_video_labels_and_actions
      render_inline(Admin::SortableListItemComponent.new(resource_type: :video, index: 1))

      assert_selector '[data-sort-handle][aria-label="Reorder video 2"]'
      assert_selector '[data-move-up-button][aria-label="Move video 2 up"]'
      assert_selector '[data-move-down-button][aria-label="Move video 2 down"]'
      assert_selector '[data-delete-button][aria-label="Delete video 2"]'
      assert_selector '[data-delete-button][data-action="click->admin--skateparks--form#removeVideo"]'
    end

    def test_renders_default_video_labels_without_index
      render_inline(Admin::SortableListItemComponent.new(resource_type: :video))

      assert_selector '[data-sort-handle][aria-label="Reorder video"]'
      assert_selector '[data-move-up-button][aria-label="Move video up"]'
      assert_selector '[data-move-down-button][aria-label="Move video down"]'
      assert_selector '[data-delete-button][aria-label="Delete video"]'
    end

    def test_renders_hidden_class_when_destroyed
      rendered = render_inline(Admin::SortableListItemComponent.new(resource_type: :image, destroyed: true))

      assert_includes rendered.to_html, 'hidden'
      assert_selector '[data-destroyed="true"]'
    end

    def test_renders_fields_preview_and_subtitle_slots
      render_inline(Admin::SortableListItemComponent.new(resource_type: :image)) do |item|
        item.with_fields { '<input type="hidden" name="test" value="1">'.html_safe }
        item.with_preview { '<img alt="test" class="test-preview">'.html_safe }
        item.with_subtitle { '<p class="test-subtitle">Info text</p>'.html_safe }
      end

      assert_selector 'input[name="test"][value="1"]', visible: :all
      assert_selector 'img.test-preview'
      assert_selector 'p.test-subtitle', text: 'Info text'
    end
  end
end
