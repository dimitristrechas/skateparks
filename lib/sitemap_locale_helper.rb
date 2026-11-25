module SitemapLocaleHelper
  DEFAULT_HOST = 'https://www.skateparks.gr'.freeze

  def add_localized(path, **options)
    alternates = I18n.available_locales.map do |locale|
      { href: localized_url(path, locale: locale), lang: locale.to_s }
    end
    alternates << { href: localized_url(path, locale: I18n.default_locale), lang: 'x-default' }

    add path, options.merge(alternates: alternates)
  end

  def localized_url(path, locale:)
    return "#{DEFAULT_HOST}#{path}" if locale.to_sym == I18n.default_locale

    "#{DEFAULT_HOST}#{path}?locale=#{locale}"
  end
end
