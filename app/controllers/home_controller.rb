class HomeController < ApplicationController
  def index
    @skateparks = Skatepark.published.order(created_at: :desc)
    @skateparks_latest = Rails.cache.fetch(Skatepark.homepage_latest_cache_key, expires_in: 1.year) do
      Skatepark.latest.includes(:skatepark_images, cover_image_attachment: :blob).to_a
    end
    @skateparks_popular = Rails.cache.fetch(Skatepark.homepage_popular_cache_key, expires_in: 1.year) do
      Skatepark.popular.includes(:skatepark_images, cover_image_attachment: :blob).to_a
    end

    @locale = params['locale']
  end

  def about
    @title = t('about.title')
    @meta_description = t('about_details')
  end

  def contact
    @title = t('contact')
    @meta_description = t('contact_details')
  end

  def privacy
    @title = t('privacy.title')
    @meta_description = t('privacy.meta_description')
  end
end
