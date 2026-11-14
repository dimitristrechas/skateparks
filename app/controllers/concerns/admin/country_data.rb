# frozen_string_literal: true

module Admin
  module CountryData
    extend ActiveSupport::Concern

    def cities
      country = ISO3166::Country[params[:country_code].to_s.upcase]
      return render(json: []) if country.blank?

      cities = CityDataset.search(country.alpha2, params[:q])

      render json: cities.map { |city|
        {
          id: city['id'],
          name: CityDataset.localized_name(city),
          location_name: CityDataset.location_name(city, country),
        }
      }
    end
  end
end
