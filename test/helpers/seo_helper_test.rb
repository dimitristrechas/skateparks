require 'test_helper'

class SeoHelperTest < ActionView::TestCase
  tests SeoHelper

  def test_social_title_falls_back_to_default_locale_application_title
    I18n.with_locale(:el) do
      assert_equal I18n.t('application.title', locale: I18n.default_locale), social_title
    end
  end

  def test_social_title_ignores_localized_page_title_assign
    controller.stubs(:view_assigns).returns({ 'title' => 'Bonn | Skateparks.gr' })

    assert_equal I18n.t('application.title', locale: I18n.default_locale), social_title
  end

  def test_social_title_uses_skatepark_default_locale_seo_title
    skatepark = create(:skatepark, meta_title_en: 'English Title', meta_title_el: 'Ελληνικός Τίτλος')
    controller.stubs(:view_assigns).returns({ 'skatepark' => skatepark })

    I18n.with_locale(:el) do
      assert_equal 'English Title', social_title
    end
  end

  def test_social_description_falls_back_to_default_locale_meta_description
    I18n.with_locale(:el) do
      assert_equal I18n.t('application.meta_description', locale: I18n.default_locale), social_description
    end
  end

  def test_social_description_uses_skatepark_default_locale_seo_description
    skatepark = create(
      :skatepark,
      meta_description_en: 'English description.',
      meta_description_el: 'Ελληνική περιγραφή.'
    )
    controller.stubs(:view_assigns).returns({ 'skatepark' => skatepark })

    I18n.with_locale(:el) do
      assert_equal 'English description.', social_description
    end
  end

  def test_social_copy_uses_default_locale_for_static_about_page
    stubs(:controller_name).returns('home')
    stubs(:action_name).returns('about')

    I18n.with_locale(:el) do
      assert_equal I18n.t('about.title', locale: I18n.default_locale), social_title
      assert_equal I18n.t('about_details', locale: I18n.default_locale), social_description
    end
  end

  def test_og_locale_uses_default_locale
    I18n.with_locale(:el) do
      assert_equal 'en_US', og_locale
    end
  end

  def test_og_locale_alternates_exclude_default_locale
    assert_equal ['el_GR'], og_locale_alternates
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
    stubs(:request).returns(
      stub(query_parameters: { 'country_code' => 'GR', 'sort' => 'popular', 'page' => '2', 'search' => 'bowl' })
    )
    stubs(:url_for).with({ only_path: false, protocol: 'https', country_code: 'GR', sort: 'popular', page: '2' })
                   .returns('https://www.skateparks.gr/skateparks?country_code=GR&page=2&sort=popular')

    assert_equal 'https://www.skateparks.gr/skateparks?country_code=GR&page=2&sort=popular', seo_page_url(locale: :en)
  end
end
