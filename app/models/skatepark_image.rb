class SkateparkImage < ApplicationRecord
  include ReorderablePosition

  belongs_to :skatepark, inverse_of: :skatepark_images, touch: true
  has_one_attached :image

  validates :image, presence: true

  before_validation :set_checksum_from_image
  after_commit :clear_homepage_caches, on: %i[create update destroy]

  private

  def set_checksum_from_image
    self.checksum = image.attached? ? image.blob.checksum : nil
  end

  def clear_homepage_caches
    Skatepark.clear_homepage_caches
  end
end
