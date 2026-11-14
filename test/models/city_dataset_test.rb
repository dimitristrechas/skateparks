require 'test_helper'

class CityDatasetTest < ActiveSupport::TestCase
  def test_for_country_loads_the_generated_dataset
    cities = CityDataset.for_country('GR')

    assert_operator cities.size, :>, 1
    assert_includes cities.pluck('id'), 264_371
  end

  def test_find_returns_a_city_with_both_names
    city = CityDataset.find('GR', 264_371)

    assert_equal 'Athens', city['name_en']
    assert_equal 'Αθήνα', city['name_el']
  end

  def test_find_many_returns_only_requested_cities
    cities = CityDataset.find_many('GR', [264_371, 734_077])

    assert_equal [264_371, 734_077], cities.pluck('id').sort
  end

  def test_search_matches_english_name
    assert_equal 734_077, CityDataset.search('GR', 'thess').first['id']
  end

  def test_search_matches_greek_name_without_accents
    assert_equal 264_371, CityDataset.search('GR', 'αθηνα').first['id']
  end

  def test_search_returns_empty_for_unknown_country
    assert_equal [], CityDataset.search('ZZ', 'Athens')
  end

  def test_localized_name_uses_the_current_locale
    city = CityDataset.find('GR', 264_371)

    assert_equal 'Athens', CityDataset.localized_name(city)

    I18n.with_locale(:el) do
      assert_equal 'Αθήνα', CityDataset.localized_name(city)
    end
  end

  def test_location_name_uses_the_translated_subdivision
    city = CityDataset.find('GR', 264_371)
    country = ISO3166::Country['GR']

    assert_equal 'Attica, Greece', CityDataset.location_name(city, country)

    I18n.with_locale(:el) do
      assert_equal 'Αττική, Ελλάδα', CityDataset.location_name(city, country)
    end
  end

  def test_region_name_uses_the_translated_subdivision
    city = CityDataset.find('GR', 264_371)
    country = ISO3166::Country['GR']

    assert_equal 'Attica', CityDataset.region_name(city, country)

    I18n.with_locale(:el) do
      assert_equal 'Αττική', CityDataset.region_name(city, country)
    end
  end
end
