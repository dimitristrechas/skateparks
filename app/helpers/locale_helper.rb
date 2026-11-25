module LocaleHelper
  LOCALE_NAMES = {
    el: 'Ελληνικά',
    en: 'English',
  }.freeze

  def locale_name(locale)
    LOCALE_NAMES.fetch(locale.to_sym)
  end

  def locale_switch_url_options(locale)
    options = {
      country_code: params[:country_code],
      city_id: params[:city_id],
      distance: params[:distance],
      lat: params[:lat],
      lng: params[:lng],
      sort: params[:sort],
      page: params[:page],
    }
    options[:locale] = locale unless locale == I18n.default_locale
    options.compact
  end
end
