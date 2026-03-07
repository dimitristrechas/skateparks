require 'test_helper'

class SchemaHelperTest < ActionView::TestCase
  def test_organization_schema_generates_correct_structure
    stubs(:root_url).returns('https://skateparks.gr/')

    schema = organization_schema

    assert_equal 'https://schema.org', schema[:@context]
    assert_equal 'Organization', schema[:@type]
    assert_equal 'skateparks.gr', schema[:name]
    assert_equal 'https://skateparks.gr/', schema[:url]
  end

  def test_website_schema_generates_correct_structure
    stubs(:root_url).returns('https://skateparks.gr/')
    stubs(:skateparks_url).returns('https://skateparks.gr/skateparks')

    schema = website_schema

    assert_equal 'https://schema.org', schema[:@context]
    assert_equal 'WebSite', schema[:@type]
    assert_equal 'skateparks.gr', schema[:name]
    assert_equal %w[el en], schema[:inLanguage]
  end

  def test_website_schema_includes_search_action
    stubs(:root_url).returns('https://skateparks.gr/')
    stubs(:skateparks_url).returns('https://skateparks.gr/skateparks')

    schema = website_schema

    assert_equal 'SearchAction', schema[:potentialAction][:@type]
    assert_includes schema[:potentialAction][:target][:urlTemplate], 'search={search_term_string}'
  end
end
