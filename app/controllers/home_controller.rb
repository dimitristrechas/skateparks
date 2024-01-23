
class HomeController < ApplicationController
  def index
    @skateparks = Skatepark.published.order(created_at: :desc)
    @locale = params["locale"]
  end

  def about
    @title = t('about')
    @meta_description =  t('about_details')
  end

  def contact
    @title = t('contact')
    @meta_description =  t('contact_details')
  end
end
