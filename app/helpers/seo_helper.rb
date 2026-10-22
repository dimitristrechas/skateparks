module SeoHelper
  LOCALE_ALTERNATE_PARAMS = %i[country_code state sort page].freeze
  OG_LOCALE_MAP = { en: 'en_US', el: 'el_GR' }.freeze

  # Static pages with per-locale titles/descriptions. Social share tags always
  # use the default-locale (English) copy so link unfurls are predictable
  # regardless of the viewer's current locale (SK8-99).
  STATIC_SOCIAL_COPY = {
    'home#about' => { title: 'about.title', description: 'about_details' },
    'home#contact' => { title: 'contact', description: 'contact_details' },
    'home#privacy' => { title: 'privacy.title', description: 'privacy.meta_description' },
  }.freeze

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
    default_locale_social_title.presence ||
      t('application.title', locale: I18n.default_locale)
  end

  def social_description
    default_locale_social_description.presence ||
      t('application.meta_description', locale: I18n.default_locale)
  end

  def social_image
    view_assigns['meta_image'].presence || image_url('logo-og.png')
  end

  def og_locale
    OG_LOCALE_MAP.fetch(I18n.default_locale, I18n.default_locale.to_s)
  end

  def og_locale_alternates
    (I18n.available_locales - [I18n.default_locale]).map do |locale|
      OG_LOCALE_MAP.fetch(locale, locale.to_s)
    end
  end

  private

  def default_locale_social_title
    return view_assigns['social_title'] if view_assigns['social_title'].present?

    skatepark = view_assigns['skatepark']
    return Mobility.with_locale(I18n.default_locale) { skatepark.seo_title } if skatepark.present?

    copy = STATIC_SOCIAL_COPY["#{controller_name}##{action_name}"]
    return t(copy[:title], locale: I18n.default_locale) if copy

    nil
  end

  def default_locale_social_description
    return view_assigns['social_description'] if view_assigns['social_description'].present?

    skatepark = view_assigns['skatepark']
    return Mobility.with_locale(I18n.default_locale) { skatepark.seo_description } if skatepark.present?

    copy = STATIC_SOCIAL_COPY["#{controller_name}##{action_name}"]
    return t(copy[:description], locale: I18n.default_locale) if copy

    nil
  end

  def view_assigns
    controller.view_assigns
  end

  def hreflang_link_tag(locale, hreflang: locale)
    tag.link(rel: 'alternate', hreflang: hreflang, href: seo_page_url(locale: locale))
  end
end
