class SkateparkImage < ApplicationRecord
  include ReorderablePosition

  belongs_to :skatepark, inverse_of: :skatepark_images, touch: true
  has_one_attached :image

  validates :image, presence: true

  after_destroy :clear_homepage_caches
  after_save :clear_homepage_caches

  private

  def clear_homepage_caches
    Skatepark.clear_homepage_caches
  end
end
