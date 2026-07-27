module SitemapLocaleHelper
  DEFAULT_HOST = 'https://www.skateparks.gr'.freeze
  DEFAULT_LOCALE = :en
  LOCALES = %i[en el].freeze

  def add_localized(path, **options)
    alternates = LOCALES.map do |locale|
      { href: localized_url(path, locale: locale), lang: locale.to_s }
    end
    alternates << { href: localized_url(path, locale: DEFAULT_LOCALE), lang: 'x-default' }

    add path, options.merge(alternates: alternates)
  end

  def localized_url(path, locale:)
    return "#{DEFAULT_HOST}#{path}" if locale == DEFAULT_LOCALE

    "#{DEFAULT_HOST}#{path}?locale=#{locale}"
  end
end
