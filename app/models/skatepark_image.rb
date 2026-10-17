class SkateparkImage < ApplicationRecord
  include ReorderablePosition

  belongs_to :skatepark, inverse_of: :skatepark_images, touch: true
  has_one_attached :image

  validates :image, presence: true

  after_commit :clear_homepage_caches, on: %i[create update destroy]

  private

  def clear_homepage_caches
    Skatepark.clear_homepage_caches
  end
end
