require "image_processing/vips"

class Skatepark < ApplicationRecord
  has_many_attached :images do |attachable|
    attachable.variant(:sm,
                       resize_and_pad: [400, 300],
                       format: :webp,
                       saver: { strip: true, quality: 50, interlace: true }
                      )
    attachable.variant(:md,
                       resize_and_pad: [800, 600],
                       format: :webp,
                       saver: { strip: true, quality: 80, interlace: true }
                      )
    attachable.variant(:lg,
                       resize_and_pad: [1600, 1200],
                       format: :webp,
                       saver: { strip: true, quality: 80, interlace: true }
                      )
  end
  has_one_attached :cover_image do |attachable|
    attachable.variant(:thumb,
                       resize_and_pad: [600, 450],
                       format: :webp,
                       saver: { strip: true, quality: 80, interlace: true }
                      )
  end

  has_rich_text :description

  validates :name, presence: true
  validates :cover_image, presence: true 
  validates :lat, presence: true
  validates :lng, presence: true
  validates :description, presence: true
  validates :images, length: { minimum: 2,  too_short: "%{count} is the minimum allowed" }
end
