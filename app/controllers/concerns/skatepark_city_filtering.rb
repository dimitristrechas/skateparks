# frozen_string_literal: true

module SkateparkCityFiltering
  extend ActiveSupport::Concern

  private

  def cities_for_country
    return [] if params[:country_code].blank?

    city_ids = cached_available_city_ids
    return [] if city_ids.empty?

    CityDataset.find_many(params[:country_code], city_ids)
               .sort_by { |city| [CityDataset.localized_name(city), city['id']] }
  end

  def cached_available_city_ids
    Rails.cache.fetch("skateparks_cities_#{params[:country_code]}", expires_in: 1.year) do
      Skatepark.published
               .where(country_code: params[:country_code])
               .distinct
               .pluck(:city_geoname_id)
               .compact
    end
  end

  def apply_location_filters(skateparks)
    skateparks = skateparks.where(country_code: params[:country_code]) if params[:country_code].present?
    skateparks = skateparks.where(city_geoname_id: params[:city_id]) if city_filter?
    skateparks
  end

  def city_filter?
    params[:city_id].present? && params[:country_code].present?
  end
end
