class Skatepark < ApplicationRecord
  extend Mobility

  translates :name, type: :string
  translates :description, backend: :action_text
  has_many_attached :images
  has_one :popular_skatepark, dependent: :destroy
  # has_many_attached :images do |attachable|
  #   attachable.variant(:sm,
  #                      resize_and_pad: [600, 450],
  #                      format: :webp,
  #                      saver: { strip: true, quality: 50, interlace: true },
  #                      preprocessed: true
  #                     )
  #   attachable.variant(:md,
  #                      resize_and_pad: [1200, 900],
  #                      format: :webp,
  #                      saver: { strip: true, quality: 80, interlace: true },
  #                      preprocessed: true
  #                     )
  #   attachable.variant(:lg,
  #                      resize_and_pad: [1600, 1200],
  #                      format: :webp,
  #                      saver: { strip: true, quality: 80, interlace: true },
  #                      preprocessed: true
  #                     )
  # end
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
  validates :images, length: { minimum: 2, too_short: '%<count>s is the minimum allowed' }
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :country_code, presence: true, inclusion: { in: ISO3166::Country.codes }
  validates :state, presence: true

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
