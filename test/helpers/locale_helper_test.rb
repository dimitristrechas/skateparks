require 'test_helper'

class LocaleHelperTest < ActionView::TestCase
  include LocaleHelper

  def test_locale_name_returns_native_names
    assert_equal 'Ελληνικά', locale_name(:el)
    assert_equal 'English', locale_name('en')
  end

  def test_locale_names_cover_available_locales
    assert_equal I18n.available_locales.sort, LocaleHelper::LOCALE_NAMES.keys.sort
  end

  def test_locale_switch_url_options_omits_default_locale
    stubs(:params).returns(ActionController::Parameters.new(country_code: 'GR', page: '2'))

    assert_equal({ country_code: 'GR', page: '2', locale: nil }, locale_switch_url_options(:en))
  end

  def test_locale_switch_url_options_includes_non_default_locale
    stubs(:params).returns(ActionController::Parameters.new(country_code: 'GR'))

    assert_equal({ country_code: 'GR', locale: :el }, locale_switch_url_options(:el))
  end

  def test_locale_switch_url_options_preserves_sort_param
    stubs(:params).returns(ActionController::Parameters.new(country_code: 'GR', sort: 'popular', page: '2'))

    assert_equal({ country_code: 'GR', sort: 'popular', page: '2', locale: :el }, locale_switch_url_options(:el))
  end

  def test_locale_switch_url_options_preserves_city_id
    stubs(:params).returns(ActionController::Parameters.new(country_code: 'GR', city_id: '264371'))

    assert_equal({ country_code: 'GR', city_id: '264371', locale: :el }, locale_switch_url_options(:el))
  end
end
