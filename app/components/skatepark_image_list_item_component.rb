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
    if position_label
      I18n.t('admin.skateparks.form.reorder_image', position: position_label)
    else
      I18n.t('admin.skateparks.form.reorder_image_default')
    end
  end

  def move_up_label
    if position_label
      I18n.t('admin.skateparks.form.move_image_up', position: position_label)
    else
      I18n.t('admin.skateparks.form.move_image_up_default')
    end
  end

  def move_down_label
    if position_label
      I18n.t('admin.skateparks.form.move_image_down', position: position_label)
    else
      I18n.t('admin.skateparks.form.move_image_down_default')
    end
  end

  def delete_label
    if position_label
      I18n.t('admin.skateparks.form.delete_image', position: position_label)
    else
      I18n.t('admin.skateparks.form.delete_image_default')
    end
  end
end
