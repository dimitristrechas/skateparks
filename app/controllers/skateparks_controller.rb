class SkateparksController < ApplicationController
  include SkateparkDistanceFiltering
  include SkateparkVisitTracking
  include SkateparkCityFiltering

  before_action :set_skatepark, only: %i[show]

  def index
    @skateparks = filtered_skateparks.page(params[:page])
    @countries = cached_countries
    @cities = cities_for_country
  end

  def show
    track_skatepark_visit
    @title = @skatepark.seo_title
    @meta_description = @skatepark.seo_description
    @meta_image = url_for(@skatepark.cover_image)
    @location_friendly_name = @skatepark.location_name(with_flag: true)
  end

  def available_cities
    @cities = cities_for_country

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('city_select', partial: 'city_select', locals: { cities: @cities })
      end
    end
  end

  private

  def set_skatepark
    skatepark_id = params[:id].to_s.split('-', 2).first
    @skatepark = published_skateparks_with_media.find(skatepark_id)

    return if @skatepark.to_param == params[:id].to_s

    redirect_to canonical_skatepark_path, status: :moved_permanently
  rescue ActiveRecord::RecordNotFound, ArgumentError
    redirect_to root_path, alert: t('skateparks.not_found')
  end

  def canonical_skatepark_path
    path = skatepark_path(@skatepark)
    query = request.query_parameters.except('locale')
    return path if query.empty?

    "#{path}#{path.include?('?') ? '&' : '?'}#{query.to_query}"
  end

  def published_skateparks_with_media
    Skatepark.published.includes(
      :active_skatepark_videos,
      cover_image_attachment: :blob,
      skatepark_images: { image_attachment: :blob }
    )
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

  def skateparks_for_filters
    skateparks = Skatepark.published.preload(:string_translations, :skatepark_images, cover_image_attachment: :blob)
    apply_location_filters(skateparks)
  end
end
