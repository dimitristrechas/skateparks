class SkateparkImageListItemComponent < ViewComponent::Base
  renders_one :fields
  renders_one :preview
  renders_one :subtitle

  def initialize(index: nil, destroyed: false)
    super()
    @index = index
    @destroyed = destroyed
  end

  private

  def position_label
    @index ? @index + 1 : nil
  end

  def item_classes
    class_names(
      'flex flex-col gap-3 bg-white p-3 sm:flex-row sm:items-center dark:bg-gray-900',
      'hidden' => @destroyed
    )
  end

  def handle_label
    position_label ? "Reorder image #{position_label}" : 'Reorder image'
  end

  def move_up_label
    position_label ? "Move image #{position_label} up" : 'Move image up'
  end

  def move_down_label
    position_label ? "Move image #{position_label} down" : 'Move image down'
  end

  def delete_label
    position_label ? "Delete image #{position_label}" : 'Delete image'
  end
end
