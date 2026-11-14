require 'test_helper'

module Admin
  class SkateparkPickerComponentTest < ViewComponent::TestCase
    def test_renders_combobox_and_hidden_input
      render_inline(
        Admin::SkateparkPickerComponent.new(
          input_name: 'popular_skatepark[skatepark_id]',
          input_id: 'popular_skatepark_skatepark_id',
          label: 'Skatepark',
          search_url: '/admin/skateparks/search'
        )
      )

      hidden_selector = 'input[type="hidden"][name="popular_skatepark[skatepark_id]"]' \
                        '[id="popular_skatepark_skatepark_id"]'

      assert_selector 'label[for="popular_skatepark_skatepark_id_combobox"]', text: 'Skatepark'
      assert_selector hidden_selector, visible: :all
      assert_selector 'input[role="combobox"][id="popular_skatepark_skatepark_id_combobox"][aria-expanded="false"]'
      assert_selector 'ul[role="listbox"][id="popular_skatepark_skatepark_id_listbox"]', visible: :all
    end

    def test_renders_selected_values_and_required_attribute
      render_inline(
        Admin::SkateparkPickerComponent.new(
          input_name: 'skatepark_id',
          input_id: 'skatepark_id',
          label: 'Assign to',
          search_url: '/admin/skateparks/search',
          selected_id: 42,
          selected_name: 'Latraac',
          required: true
        )
      )

      assert_selector 'input[type="hidden"][value="42"]', visible: :all
      assert_selector 'input[role="combobox"][value="Latraac"][required]'
      assert_selector '[data-controller="admin--skatepark-picker"][data-admin--skatepark-picker-required-value="true"]'
    end

    def test_renders_localized_strings_in_greek
      I18n.with_locale(:el) do
        render_inline(
          Admin::SkateparkPickerComponent.new(
            input_name: 'skatepark_id',
            input_id: 'skatepark_id',
            label: I18n.t('admin.video_suggestions.assign_to'),
            search_url: '/admin/skateparks/search'
          )
        )

        no_results_text = I18n.t('admin.skatepark_picker.no_results')

        assert_selector "input[placeholder='#{I18n.t('admin.skatepark_picker.placeholder')}']"
        assert_selector "[data-admin--skatepark-picker-no-results-text-value='#{no_results_text}']"
      end
    end

    def test_renders_custom_texts_for_city_picker
      render_inline(
        Admin::SkateparkPickerComponent.new(
          input_name: 'skatepark[city_geoname_id]',
          input_id: 'skatepark_city_geoname_id',
          label: 'City',
          search_url: '/admin/cities?country_code=GR',
          no_results_text: 'No matching cities found.',
          results_count_one: '1 city available',
          results_count_other: 'N cities available',
          selection_required_text: 'Please select a city from the list.'
        )
      )

      assert_selector '[data-admin--skatepark-picker-no-results-text-value="No matching cities found."]'
      assert_selector '[data-admin--skatepark-picker-results-count-one-value="1 city available"]'
      assert_selector '[data-admin--skatepark-picker-results-count-other-value="N cities available"]'
      assert_selector '[data-admin--skatepark-picker-selection-required-value="Please select a city from the list."]'
    end
  end
end
