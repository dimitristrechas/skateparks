class ApplicationController < ActionController::Base
  around_action :switch_locale
  before_action :redirect_default_locale_param, if: -> { request.get? || request.head? }

  def switch_locale(&)
    locale = params[:locale] || I18n.default_locale
    if I18n.available_locales.map(&:to_s).include?(locale)
      I18n.with_locale(locale, &)
    else
      I18n.with_locale(I18n.default_locale, &)
    end
  end

  def default_url_options
    return {} if I18n.locale == I18n.default_locale

    { locale: I18n.locale }
  end

  private

  def redirect_default_locale_param
    return if params[:locale].blank?
    return unless params[:locale].to_s == I18n.default_locale.to_s

    destination = request.path_parameters.merge(
      request.query_parameters.except('locale').symbolize_keys
    )

    redirect_to url_for(destination), status: :moved_permanently, allow_other_host: false
  end
end
