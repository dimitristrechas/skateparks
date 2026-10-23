module Admin
  class SkateparkPickerComponent < ViewComponent::Base
    # rubocop:disable-next Metrics/ParameterLists
    def initialize(input_name:, input_id:, label:, search_url:,
                   placeholder: nil, selected_id: nil, selected_name: nil, required: false)
      super()
      @input_name = input_name
      @input_id = input_id
      @label = label
      @search_url = search_url
      @placeholder = placeholder || I18n.t('admin.skatepark_picker.placeholder')
      @selected_id = selected_id
      @selected_name = selected_name
      @required = required
    end

    private

    def combobox_input_id
      "#{@input_id}_combobox"
    end

    def listbox_id
      "#{@input_id}_listbox"
    end

    def error_id
      "#{@input_id}_error"
    end
  end
end
