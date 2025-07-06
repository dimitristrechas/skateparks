class Skatepark < ApplicationRecord
  extend Mobility
  translates :name, type: :string
  translates :description, backend: :action_text
  has_many_attached :images
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
end
