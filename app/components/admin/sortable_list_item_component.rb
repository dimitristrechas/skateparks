module Admin
  class SortableListItemComponent < ViewComponent::Base
    renders_one :fields
    renders_one :preview
    renders_one :subtitle
    renders_one :status

    def initialize(resource_type:, index: nil, destroyed: false)
      super()
      @resource_type = resource_type.to_sym
      @index = index
      @destroyed = destroyed
    end

    private

    def position_label
      @index ? @index + 1 : nil
    end

    def item_classes
      class_names(
        'grid grid-cols-1 gap-3 bg-white p-3 sm:items-center dark:bg-gray-900',
        ('sm:grid-cols-[auto_auto_1fr_minmax(auto,12rem)_auto]' if status?),
        ('sm:grid-cols-[auto_auto_1fr_auto]' unless status?),
        'hidden' => @destroyed
      )
    end

    def resource_label
      I18n.t("admin.skateparks.form.#{@resource_type}_label")
    end

    def handle_label
      label_for(:reorder)
    end

    def move_up_label
      label_for(:move_up)
    end

    def move_down_label
      label_for(:move_down)
    end

    def delete_label
      label_for(:delete)
    end

    def delete_action
      "click->admin--skateparks--form#remove#{@resource_type.to_s.camelize}"
    end

    def label_for(action)
      if position_label
        I18n.t("admin.skateparks.form.#{translation_key_for(action)}", position: position_label)
      else
        I18n.t("admin.skateparks.form.#{translation_key_for(action)}_default")
      end
    end

    def translation_key_for(action)
      case action
      when :reorder
        "reorder_#{@resource_type}"
      when :move_up
        "move_#{@resource_type}_up"
      when :move_down
        "move_#{@resource_type}_down"
      when :delete
        "delete_#{@resource_type}"
      end
    end
  end
end
