class SkateparkImage < ApplicationRecord
  include ReorderablePosition

  belongs_to :skatepark, inverse_of: :skatepark_images, touch: true
  has_one_attached :image

  validates :image, presence: true
end
