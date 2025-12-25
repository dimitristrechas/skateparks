module LocaleHelper
  LOCALES = {
    el: 'Ελληνικά',
    en: 'English',
  }.freeze

  def locale_selector
    content_tag :div, class: 'relative' do
      safe_join([
                  content_tag(:div, LOCALES[I18n.locale], class: 'cursor-pointer'),
                  locale_list,
                ])
    end
  end

  private

  def locale_list
    content_tag(:ul, class: 'absolute inset-x-0 bottom-0 bg-white') do
      safe_join(I18n.available_locales.map { |locale| content_tag(:li, locale_link(locale)) })
    end
  end

  def locale_link(locale)
    link_to LOCALES[locale],
            { locale: locale, country_code: params[:country_code], state: params[:state], page: params[:page] }.compact
  end
end
