class HomeController < ApplicationController
  def index
    @skateparks = Skatepark.published.order(created_at: :desc)
    @skateparks_latest = Rails.cache.fetch('skateparks_latest', expires_in: 1.year) do
      Skatepark.latest.to_a
    end
    @skateparks_popular = Rails.cache.fetch('skateparks_popular', expires_in: 1.year) do
      Skatepark.popular.to_a
    end

    @locale = params['locale']
  end

  def about
    @title = t('about')
    @meta_description = t('about_details')
  end

  def contact
    @title = t('contact')
    @meta_description = t('contact_details')
  end
end
