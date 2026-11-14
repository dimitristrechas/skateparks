module Admin
  class SkateparkPickerComponent < ViewComponent::Base
    # rubocop:disable-next Metrics/ParameterLists
    def initialize(input_name:, input_id:, label:, search_url:,
                   placeholder: nil, selected_id: nil, selected_name: nil, required: false,
                   no_results_text: nil, results_count_one: nil, results_count_other: nil,
                   selection_required_text: nil)
      super()
      @input_name = input_name
      @input_id = input_id
      @label = label
      @search_url = search_url
      @placeholder = placeholder || I18n.t('admin.skatepark_picker.placeholder')
      @selected_id = selected_id
      @selected_name = selected_name
      @required = required
      @no_results_text = no_results_text || I18n.t('admin.skatepark_picker.no_results')
      @results_count_one = results_count_one || I18n.t('admin.skatepark_picker.results_count_one')
      @results_count_other = results_count_other ||
                             I18n.t('admin.skatepark_picker.results_count_other', count: '{count}')
      @selection_required_text = selection_required_text || I18n.t('admin.skatepark_picker.selection_required')
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
