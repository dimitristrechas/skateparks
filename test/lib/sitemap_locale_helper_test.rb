require 'test_helper'
require Rails.root.join('lib/sitemap_locale_helper')

class SitemapLocaleHelperTest < ActiveSupport::TestCase
  include SitemapLocaleHelper

  def test_localized_url_omits_locale_param_for_default_locale
    assert_equal 'https://www.skateparks.gr/skateparks/1-test', localized_url('/skateparks/1-test', locale: :en)
  end

  def test_localized_url_includes_locale_param_for_non_default_locale
    assert_equal 'https://www.skateparks.gr/skateparks/1-test?locale=el',
                 localized_url('/skateparks/1-test', locale: :el)
  end

  def test_add_localized_builds_hreflang_alternates
    added = []
    define_singleton_method(:add) do |path, options|
      added << [path, options]
    end

    add_localized '/about'

    assert_equal 1, added.size
    path, options = added.first

    assert_equal '/about', path
    assert_equal [
      { href: 'https://www.skateparks.gr/about', lang: 'en' },
      { href: 'https://www.skateparks.gr/about?locale=el', lang: 'el' },
      { href: 'https://www.skateparks.gr/about', lang: 'x-default' },
    ], options[:alternates]
  end
end
