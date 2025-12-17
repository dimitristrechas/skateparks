module LocaleHelper
  LOCALES = {
    el: 'Ελληνικά',
    en: 'English',
  }.freeze

  def locale_selector
    active_locale = I18n.locale

    content_tag :div, class: 'relative' do
      elements = [
        content_tag(:div, LOCALES[active_locale], class: 'cursor-pointer'),
      ]
      elements << content_tag(:ul, class: 'absolute inset-x-0 bottom-0 bg-white') do
        links = []
        I18n.available_locales.each do |locale|
          link = link_to LOCALES[locale],
                         { locale: locale, country_code: params[:country_code], state: params[:state],
                           page: params[:page], }.compact
          links << content_tag(:li, link)
        end
        links.join.html_safe
      end
      elements.join.html_safe
    end
  end
end
