module SkateparkDistanceFiltering
  extend ActiveSupport::Concern

  DISTANCE_FILTER_OPTIONS = [5, 10, 25].freeze
  DEFAULT_DISTANCE_FILTER = 5
  MAX_EARTH_DISTANCE_KM = 40_075
  SORT_OPTIONS = %w[alphabetical popular newest nearest].freeze
  DEFAULT_SORT_OPTION = 'alphabetical'.freeze

  included do
    helper_method :default_distance_filter,
                  :distance_filter_options,
                  :location_params_present?,
                  :coordinates_valid?,
                  :sort_options,
                  :selected_sort_option
  end

  private

  def apply_distance_filter(skateparks)
    if distance_params_valid?
      apply_distance_sort_order(
        skateparks.near([distance_latitude, distance_longitude], distance_radius, units: :km)
      )
    elsif selected_sort_option == 'nearest'
      skateparks.near([distance_latitude, distance_longitude], MAX_EARTH_DISTANCE_KM, units: :km)
    else
      apply_sort_order(skateparks)
    end
  end

  def apply_sort_order(skateparks)
    case selected_sort_option
    when 'popular'
      skateparks.most_popular
    when 'newest'
      skateparks.newest
    else
      skateparks.i18n.order(:name).order(id: :asc)
    end
  end

  def apply_distance_sort_order(skateparks)
    case selected_sort_option
    when 'popular'
      skateparks.reorder(visits_count: :desc).order(Arel.sql('distance ASC'), id: :asc)
    when 'newest'
      skateparks.reorder(created_at: :desc, id: :desc)
    when 'alphabetical'
      order_distance_results_alphabetically(skateparks)
    else
      skateparks
    end
  end

  def order_distance_results_alphabetically(skateparks)
    translation_subquery = Mobility::Backends::ActiveRecord::KeyValue::StringTranslation
                           .where(translatable_type: 'Skatepark', key: 'name', locale: I18n.locale.to_s)
                           .where('mobility_string_translations.translatable_id = skateparks.id')
                           .select(:value)
                           .limit(1)

    skateparks.reorder(Arel.sql("(#{translation_subquery.to_sql}) ASC")).order(id: :asc)
  end

  def sort_options
    SORT_OPTIONS
  end

  def selected_sort_option
    sort = params[:sort].to_s
    if sort == 'nearest'
      return coordinates_valid? ? 'nearest' : DEFAULT_SORT_OPTION
    end
    return sort if sort_options.include?(sort)
    return 'nearest' if distance_params_valid?

    DEFAULT_SORT_OPTION
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

  def coordinates_valid?
    distance_latitude.present? && distance_longitude.present?
  end

  def distance_params_valid?
    coordinates_valid? && distance_filter_options.include?(distance_radius)
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
