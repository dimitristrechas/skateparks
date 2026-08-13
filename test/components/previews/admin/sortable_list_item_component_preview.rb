# frozen_string_literal: true

module Admin
  class SortableListItemComponentPreview < ViewComponent::Preview
    def image_item
      render(Admin::SortableListItemComponent.new(resource_type: :image, index: 0)) do |item|
        item.with_fields { '<span class="text-sm">Cover image</span>'.html_safe }
        item.with_preview do
          '<div class="size-16 rounded bg-neutral-200 dark:bg-neutral-700" aria-hidden="true"></div>'.html_safe
        end
      end
    end

    def video_item
      render(Admin::SortableListItemComponent.new(resource_type: :video, index: 1)) do |item|
        item.with_fields { '<span class="text-sm">Skatepark video</span>'.html_safe }
        item.with_preview do
          '<div class="size-16 rounded bg-neutral-200 dark:bg-neutral-700" aria-hidden="true"></div>'.html_safe
        end
        item.with_subtitle { '<span class="text-xs text-neutral-500">YouTube</span>'.html_safe }
      end
    end
  end
end
