# frozen_string_literal: true

require 'json'
require 'fileutils'

namespace :cities do
  desc <<~DESC
    Generate per-country city JSON files from GeoNames dumps.

    Download these files into tmp/geonames (or set GEONAMES_DIR):
      https://download.geonames.org/export/dump/cities1000.zip
      https://download.geonames.org/export/dump/alternateNamesV2.zip
      https://download.geonames.org/export/dump/admin1CodesASCII.txt

    Extracted filenames: cities1000.txt, alternateNamesV2.txt, admin1CodesASCII.txt.
    The generated files are committed to db/data/cities.
  DESC
  task import: :environment do
    input_dir = Pathname(ENV.fetch('GEONAMES_DIR', Rails.root.join('tmp/geonames')))
    output_dir = Pathname(ENV.fetch('CITIES_OUTPUT_DIR', Rails.root.join('db/data/cities')))
    cities_file = input_dir.join('cities1000.txt')
    alternate_names_file = input_dir.join('alternateNamesV2.txt')
    admin1_file = input_dir.join('admin1CodesASCII.txt')

    [cities_file, alternate_names_file, admin1_file].each do |file|
      abort("Missing #{file}. See the task description for the GeoNames downloads.") unless file.exist?
    end

    FileUtils.mkdir_p(output_dir)

    admin1_names = {}
    File.foreach(admin1_file, encoding: 'UTF-8') do |line|
      code, name, ascii_name, = line.chomp.split("\t", -1)
      admin1_names[code] = { name: name, ascii_name: ascii_name }
    end

    cities = []
    File.foreach(cities_file, encoding: 'UTF-8') do |line|
      fields = line.chomp.split("\t", -1)
      next unless fields[6] == 'P'

      cities << {
        id: fields[0].to_i,
        name: fields[1],
        latitude: fields[4].to_f,
        longitude: fields[5].to_f,
        country_code: fields[8],
        admin1: fields[10],
        population: fields[14].to_i,
      }
    end

    city_ids = cities.to_set { |city| city[:id] }
    alternate_names = Hash.new { |hash, key| hash[key] = {} }

    File.foreach(alternate_names_file, encoding: 'UTF-8') do |line|
      fields = line.chomp.split("\t", -1)
      geoname_id = fields[1].to_i
      next unless city_ids.include?(geoname_id)
      next unless %w[en el].include?(fields[2])
      next if fields[7] == '1' # historic
      next if fields[6] == '1' # colloquial
      next if fields[3].blank?

      language = fields[2].to_sym
      preferred = fields[4] == '1'
      current = alternate_names[geoname_id][language]

      alternate_names[geoname_id][language] = { name: fields[3], preferred: preferred } if
        current.nil? || (preferred && !current[:preferred])
    end

    subdivision_cache = {}

    cities.group_by { |city| city[:country_code] }.each do |country_code, country_cities|
      next if country_code.blank?

      records = country_cities.map do |city|
        english_name = alternate_names[city[:id]][:en]&.dig(:name)
        english_name = city[:name] if english_name.blank?
        greek_name = alternate_names[city[:id]][:el]&.dig(:name)
        greek_name = country_code == 'GR' ? city[:name] : english_name if greek_name.blank?

        admin1_key = "#{country_code}.#{city[:admin1]}"
        admin1_name = admin1_names[admin1_key]&.dig(:name)

        {
          id: city[:id],
          name_en: english_name,
          name_el: greek_name,
          population: city[:population],
          lat: city[:latitude].round(6),
          lng: city[:longitude].round(6),
          admin1: city[:admin1].presence,
          admin1_name: admin1_name.presence,
          subdivision: subdivision_code_for(
            country_code,
            city[:admin1],
            admin1_name,
            subdivision_cache
          ),
        }.compact
      end

      records.sort_by! { |record| [-record[:population].to_i, record[:name_en].to_s, record[:id]] }

      File.write(output_dir.join("#{country_code}.json"), JSON.generate(records))
    end

    country_count = cities.to_set { |city| city[:country_code] }.size

    puts "Wrote #{cities.size} cities across #{country_count} countries to #{output_dir}"
  end
end

def subdivision_code_for(country_code, admin1, admin1_name, cache)
  cache_key = [country_code, admin1]
  return cache[cache_key] if cache.key?(cache_key)

  country = ISO3166::Country[country_code]
  cache[cache_key] = if country.blank?
                       nil
                     elsif admin1.present? && country.subdivisions.key?(admin1)
                       admin1
                     else
                       find_subdivision_code(country, admin1_name)
                     end
end

def find_subdivision_code(country, admin1_name)
  normalized_name = normalize_name(admin1_name)
  return if normalized_name.blank?

  subdivision = country.subdivisions.values.find do |candidate|
    names = [candidate.name, candidate.translations[:en], candidate.translations[I18n.default_locale]]
    names.compact.any? { |name| normalize_name(name) == normalized_name }
  end

  subdivision&.code
end

def normalize_name(value)
  value.to_s.unicode_normalize(:nfd).gsub(/\p{Mn}/, '').downcase.gsub(/[^a-z0-9]/, '')
end
