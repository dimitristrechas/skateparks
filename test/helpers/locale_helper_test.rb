require 'test_helper'

class LocaleHelperTest < ActionView::TestCase
  include LocaleHelper

  def test_locales_constant_defines_greek_locale
    assert_equal 'Ελληνικά', LocaleHelper::LOCALES[:el]
  end

  def test_locales_constant_defines_english_locale
    assert_equal 'English', LocaleHelper::LOCALES[:en]
  end

  def test_locales_constant_is_frozen
    assert_predicate LocaleHelper::LOCALES, :frozen?
  end

  def test_locale_switch_url_options_omits_default_locale
    stubs(:params).returns(ActionController::Parameters.new(country_code: 'GR', page: '2'))

    assert_equal({ country_code: 'GR', page: '2' }, locale_switch_url_options(:en))
  end

  def test_locale_switch_url_options_includes_non_default_locale
    stubs(:params).returns(ActionController::Parameters.new(country_code: 'GR'))

    assert_equal({ country_code: 'GR', locale: :el }, locale_switch_url_options(:el))
  end
end
