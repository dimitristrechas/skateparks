module SkateparkDistanceFiltering
  extend ActiveSupport::Concern

  DISTANCE_FILTER_OPTIONS = [5, 10, 25].freeze
  DEFAULT_DISTANCE_FILTER = 5

  included do
    helper_method :default_distance_filter, :distance_filter_options, :location_params_present?
  end

  private

  def apply_distance_filter(skateparks)
    return skateparks.i18n.order(:name) unless distance_params_valid?

    skateparks.near([distance_latitude, distance_longitude], distance_radius, units: :km)
  end

  def default_distance_filter
    DEFAULT_DISTANCE_FILTER
  end

  def distance_filter_options
    DISTANCE_FILTER_OPTIONS
  end

  def location_params_present?
    params[:lat].present? && params[:lng].present?
  end

  def distance_params_valid?
    distance_latitude.present? && distance_longitude.present? && distance_filter_options.include?(distance_radius)
  end

  def distance_latitude
    @distance_latitude ||= parse_coordinate(params[:lat], -90.0..90.0)
  end

  def distance_longitude
    @distance_longitude ||= parse_coordinate(params[:lng], -180.0..180.0)
  end

  def distance_radius
    @distance_radius ||= Integer(params[:distance], exception: false)
  end

  def parse_coordinate(value, range)
    return if value.blank?

    coordinate = Float(value, exception: false)
    return unless coordinate && range.cover?(coordinate)

    coordinate
  end
end
