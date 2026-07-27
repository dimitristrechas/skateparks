require 'test_helper'

class SeoHelperTest < ActionView::TestCase
  tests SeoHelper

  def test_social_title_falls_back_to_application_title
    assert_equal I18n.t('application.title'), social_title
  end

  def test_social_title_uses_assigned_title
    controller.stubs(:view_assigns).returns({ 'title' => 'Bonn | Skateparks.gr' })

    assert_equal 'Bonn | Skateparks.gr', social_title
  end

  def test_social_description_falls_back_to_application_meta_description
    assert_equal I18n.t('application.meta_description'), social_description
  end

  def test_social_image_falls_back_to_logo
    assert_includes social_image, 'logo-og.png'
  end

  def test_seo_page_url_omits_locale_param_for_default_locale
    stubs(:request).returns(stub(query_parameters: {}))
    stubs(:url_for).with({ only_path: false, protocol: 'https' }).returns('https://www.skateparks.gr/skateparks/1-test')

    assert_equal 'https://www.skateparks.gr/skateparks/1-test', seo_page_url(locale: :en)
  end

  def test_seo_page_url_includes_locale_param_for_non_default_locale
    stubs(:request).returns(stub(query_parameters: {}))
    stubs(:url_for).with({ only_path: false, protocol: 'https', locale: :el })
                   .returns('https://www.skateparks.gr/skateparks/1-test?locale=el')

    assert_equal 'https://www.skateparks.gr/skateparks/1-test?locale=el', seo_page_url(locale: :el)
  end

  def test_seo_page_url_preserves_filter_query_params
    stubs(:request).returns(stub(query_parameters: { 'country_code' => 'GR', 'page' => '2', 'search' => 'bowl' }))
    stubs(:url_for).with({ only_path: false, protocol: 'https', country_code: 'GR', page: '2' })
                   .returns('https://www.skateparks.gr/skateparks?country_code=GR&page=2')

    assert_equal 'https://www.skateparks.gr/skateparks?country_code=GR&page=2', seo_page_url(locale: :en)
  end
end
