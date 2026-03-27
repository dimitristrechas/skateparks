class SkateparkImage < ApplicationRecord
  belongs_to :skatepark, inverse_of: :skatepark_images, touch: true
  has_one_attached :image

  validates :image, presence: true
  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
