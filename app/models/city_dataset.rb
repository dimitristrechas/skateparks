# frozen_string_literal: true

# Read-only access to the GeoNames-derived city dataset in db/data/cities.
# Each country is stored as a JSON array and loaded lazily into Rails.cache.
module CityDataset
  DATA_DIR = Rails.root.join('db/data/cities')
  SEARCH_LIMIT = 20
  CACHE_EXPIRES_IN = 1.day
  INDEX_CACHE_LIMIT = 3
  INDEX_CACHE_MUTEX = Mutex.new

  @indexes = {}

  module_function

  def for_country(country_code)
    code = country_code.to_s.upcase
    return [] unless code.match?(/\A[A-Z]{2}\z/)

    path = DATA_DIR.join("#{code}.json")
    return [] unless path.exist?

    Rails.cache.fetch("city_dataset/#{code}/#{path.mtime.to_i}", expires_in: CACHE_EXPIRES_IN) do
      JSON.parse(path.read)
    end
  end

  def find(country_code, id)
    index_for(country_code)[:by_id][id.to_i]
  end

  def find_many(country_code, ids)
    by_id = index_for(country_code)[:by_id]
    ids.filter_map { |id| by_id[id.to_i] }
  end

  def search(country_code, query, limit: SEARCH_LIMIT)
    term = normalize(query)
    matches = matching_cities(index_for(country_code)[:cities], term)

    sorted_cities(matches, term).first(limit)
  end

  def localized_name(city)
    name = I18n.locale == :el ? city['name_el'] : city['name_en']
    name.presence || city['name_en'].presence || city['name_el']
  end

  def location_name(city, country, locale: I18n.locale)
    region = region_name(city, country, locale: locale)
    country_name = country&.translation(locale) || country&.alpha2

    [region, country_name].compact_blank.join(', ')
  end

  def normalize(value)
    value.to_s.unicode_normalize(:nfd).gsub(/\p{Mn}/, '').downcase
  end

  def region_name(city, country, locale: I18n.locale)
    return if city.blank?

    subdivision_code = city['subdivision']

    if subdivision_code.present? && country
      subdivision = country.subdivisions[subdivision_code]
      return subdivision.translations&.[](locale) || subdivision.name if subdivision
    end

    city['admin1_name']
  end

  def matching_cities(cities, term)
    return cities if term.blank?

    cities.select { |city| matches_query?(city, term) }
  end

  def matches_query?(city, term)
    normalize(city['name_en']).include?(term) || normalize(city['name_el']).include?(term)
  end

  def sorted_cities(cities, term)
    cities.sort_by do |city|
      english_name = normalize(city['name_en'])
      greek_name = normalize(city['name_el'])
      prefix_match = prefix_match?(english_name, greek_name, term)

      [prefix_match ? 0 : 1, -city['population'].to_i, english_name, city['id']]
    end
  end

  def prefix_match?(english_name, greek_name, term)
    term.blank? || english_name.start_with?(term) || greek_name.start_with?(term)
  end

  def index_for(country_code)
    code = country_code.to_s.upcase
    return empty_index unless code.match?(/\A[A-Z]{2}\z/)

    path = DATA_DIR.join("#{code}.json")
    return empty_index unless path.exist?

    key = [code, path.mtime.to_i]

    INDEX_CACHE_MUTEX.synchronize do
      entry = @indexes.delete(key) || build_index(for_country(code))
      @indexes[key] = entry
      @indexes.shift while @indexes.size > INDEX_CACHE_LIMIT
      entry
    end
  end

  def build_index(cities)
    { cities: cities, by_id: cities.index_by { |city| city['id'] } }
  end

  def empty_index
    { cities: [], by_id: {} }
  end

  private_class_method :matching_cities, :matches_query?, :sorted_cities, :prefix_match?,
                       :index_for, :build_index, :empty_index
end
