module SeoHelper
  LOCALE_ALTERNATE_PARAMS = %i[country_code state page].freeze

  def public_seo_page?
    !request.path.start_with?('/admin')
  end

  def seo_page_url(locale:)
    url_options = { only_path: false, protocol: 'https' }
    url_options[:locale] = locale unless locale == I18n.default_locale

    url_for(
      url_options.merge(request.query_parameters.symbolize_keys.slice(*LOCALE_ALTERNATE_PARAMS))
    )
  end

  def canonical_url
    seo_page_url(locale: I18n.locale)
  end

  def hreflang_link_tags
    safe_join(
      I18n.available_locales.map { |locale| hreflang_link_tag(locale) } +
        [hreflang_link_tag(I18n.default_locale, hreflang: 'x-default')],
      "\n"
    )
  end

  def social_title
    view_assigns['title'].presence || t('application.title')
  end

  def social_description
    view_assigns['meta_description'].presence || t('application.meta_description')
  end

  def social_image
    view_assigns['meta_image'].presence || image_url('logo-og.png')
  end

  private

  def view_assigns
    controller.view_assigns
  end

  def hreflang_link_tag(locale, hreflang: locale)
    tag.link(rel: 'alternate', hreflang: hreflang, href: seo_page_url(locale: locale))
  end
end
