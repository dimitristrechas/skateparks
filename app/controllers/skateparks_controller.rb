class SkateparksController < ApplicationController
  include SkateparkDistanceFiltering

  before_action :set_skatepark, only: %i[show]

  def index
    @skateparks = filtered_skateparks.page(params[:page])
    @countries = cached_countries
    @states = states_for_country
  end

  def show
    @title = "#{@skatepark.name} | Skateparks.gr"
    @meta_description = @skatepark.description.to_plain_text
    @meta_image = url_for(@skatepark.cover_image)
    @location_friendly_name = location_name
  end

  def available_states
    @states = states_for_country

    respond_to do |format|
      format.json { render json: @states }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('state_select', partial: 'state_select', locals: { states: @states })
      end
    end
  end

  private

  def set_skatepark
    @skatepark = Skatepark.published.includes(
      :skatepark_videos,
      cover_image_attachment: :blob,
      skatepark_images: { image_attachment: :blob }
    ).find(params[:id])
  end

  def skatepark_params
    params.expect(skatepark: [:name, :lat, :lng, :country_code, :state, { images: [] }])
  end

  def filtered_skateparks
    apply_distance_filter(skateparks_for_filters)
  end

  def cached_countries
    Rails.cache.fetch('skateparks_countries', expires_in: 1.year) do
      Skatepark.published.distinct.pluck(:country_code).filter_map do |code|
        ISO3166::Country[code] if code.present?
      end
    end
  end

  def states_for_country
    return [] if params[:country_code].blank?

    available_states = cached_available_states
    filter_subdivisions_by_availability(available_states)
  end

  def cached_available_states
    Rails.cache.fetch("skateparks_states_#{params[:country_code]}", expires_in: 1.year) do
      Skatepark.published
               .where(country_code: params[:country_code])
               .distinct
               .pluck(:state)
               .compact
    end
  end

  def filter_subdivisions_by_availability(available_states)
    country = ISO3166::Country[params[:country_code]]
    return [] unless country

    country.subdivisions.values
           .select { |subdivision| available_states.include?(subdivision.code) }
           .sort_by(&:name)
  end

  def location_name
    @country_friendly_name = ISO3166::Country[@skatepark.country_code].translation(I18n.locale)
    @state_friendly_name = ISO3166::Country[@skatepark.country_code].subdivisions[@skatepark.state].code_with_translations[@skatepark.state][I18n.locale]
    @country_emoji = ISO3166::Country[@skatepark.country_code]&.emoji_flag || ''

    "#{@state_friendly_name}, #{@country_friendly_name} #{@country_emoji}"
  end

  def skateparks_for_filters
    skateparks = Skatepark.published.includes(:string_translations, :skatepark_images, cover_image_attachment: :blob)
    skateparks = skateparks.where(country_code: params[:country_code]) if params[:country_code].present?
    skateparks = skateparks.where(state: params[:state]) if params[:state].present? && params[:country_code].present?
    skateparks
  end
end
