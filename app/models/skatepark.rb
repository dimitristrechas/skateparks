class Skatepark < ApplicationRecord
  extend Mobility

  translates :name, type: :string
  translates :description, backend: :action_text
  has_many :skatepark_images, -> { order(:position, :id) }, dependent: :destroy, inverse_of: :skatepark
  accepts_nested_attributes_for :skatepark_images, allow_destroy: true
  has_one :popular_skatepark, dependent: :destroy
  has_one_attached :cover_image
  # has_one_attached :cover_image do |attachable|
  #   attachable.variant(:thumb,
  #                      resize_and_pad: [1200, 900],
  #                      format: :webp,
  #                      saver: { strip: true, quality: 80, interlace: true },
  #                      preprocessed: true
  #                     )
  # end

  enum :status, { draft: 0, published: 1, archived: 2 }

  scope :latest, -> { published.order(created_at: :desc).limit(3) }
  scope :popular, -> { joins(:popular_skatepark).merge(PopularSkatepark.all) }

  validates :name, presence: true
  validates :cover_image, presence: true
  validates :lat, presence: true
  validates :lng, presence: true
  validates :description, presence: true
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :country_code, presence: true, inclusion: { in: ISO3166::Country.codes }
  validates :state, presence: true
  validate :minimum_skatepark_images
  validate :unique_uploaded_image_filenames

  after_validation :set_slug, only: %i[create update]
  after_destroy :clear_countries_cache, :clear_location_caches, :clear_skateparks_latest_cache
  after_save :clear_countries_cache, :clear_location_caches, :clear_skateparks_latest_cache

  def to_param
    "#{id}-#{slug}"
  end

  def country
    ISO3166::Country[country_code]
  end

  def state_name
    country.subdivisions[state]&.name if state.present?
  end

  private

  def minimum_skatepark_images
    valid_images_count = skatepark_images.reject(&:marked_for_destruction?).count do |skatepark_image|
      skatepark_image.image.attached?
    end

    return if valid_images_count >= 2

    errors.add(:images, '2 is the minimum allowed')
  end

  def unique_uploaded_image_filenames
    duplicate_uploaded_image_filenames.each do |filename|
      errors.add(:images, "#{filename} has already been uploaded")
    end
  end

  def duplicate_uploaded_image_filenames
    active_skatepark_images
      .group_by { |skatepark_image| normalized_image_filename(skatepark_image) }
      .filter_map do |_normalized_filename, image_records|
        next if image_records.one?
        next unless image_records.any?(&:new_record?)

        image_records.last.image.filename.to_s
      end
  end

  def active_skatepark_images
    skatepark_images.reject(&:marked_for_destruction?).select do |skatepark_image|
      skatepark_image.image.attached?
    end
  end

  def normalized_image_filename(skatepark_image)
    skatepark_image.image.filename.to_s.strip.downcase
  end

  def set_slug
    self.slug = name_en.to_s.parameterize
  end

  def clear_countries_cache
    Rails.cache.delete('skateparks_countries') if saved_change_to_country_code? || saved_change_to_status?
  end

  def clear_location_caches
    return unless saved_change_to_country_code? || saved_change_to_state? || saved_change_to_status?

    Rails.cache.delete('skateparks_countries')
    Rails.cache.delete("skateparks_states_#{country_code}") if country_code.present?
    Rails.cache.delete("skateparks_states_#{country_code_before_last_save}") if country_code_before_last_save.present?
  end

  def clear_skateparks_latest_cache
    return unless saved_change_to_country_code? || saved_change_to_status?

    Rails.cache.delete('skateparks_latest')
  end
end
