class PopularSkatepark < ApplicationRecord
  belongs_to :skatepark

  default_scope { order(position: :asc, created_at: :desc) }

  validates :skatepark_id, uniqueness: true
  validates :position, presence: true

  after_destroy :clear_skateparks_popular_cache
  after_save :clear_skateparks_popular_cache

  private

  def clear_skateparks_popular_cache
    Rails.cache.delete(Skatepark.homepage_popular_cache_key)
  end
end
