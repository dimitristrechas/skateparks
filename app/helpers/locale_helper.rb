module LocaleHelper

  LOCALES = {
    :el => "Ελληνικά",
    :en => "English"
  }

  def locale_selector
    active_locale = I18n.locale
  
    content_tag :div, class: 'relative' do
      elements = [
        content_tag(:div, LOCALES[active_locale], class: 'cursor-pointer')
      ]
      elements << content_tag(:ul, class: "absolute inset-x-0 bottom-0 bg-white") do
        links = []
        I18n.available_locales.each do |locale|
          link = link_to LOCALES[locale], params.permit(:locale).merge(:locale => locale)
          links << content_tag(:li, link)
        end
        links.join.html_safe
      end
      elements.join.html_safe
    end
  end

end