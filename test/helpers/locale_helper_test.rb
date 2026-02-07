require 'test_helper'

class LocaleHelperTest < ActionView::TestCase
  def test_locales_constant_defines_greek_locale
    assert_equal 'Ελληνικά', LocaleHelper::LOCALES[:el]
  end

  def test_locales_constant_defines_english_locale
    assert_equal 'English', LocaleHelper::LOCALES[:en]
  end

  def test_locales_constant_is_frozen
    assert LocaleHelper::LOCALES.frozen?
  end
end
