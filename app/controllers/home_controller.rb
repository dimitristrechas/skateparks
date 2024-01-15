
class HomeController < ApplicationController
  def index
    @skateparks = Skatepark.published.order(created_at: :desc)
    @locale = params["locale"]
  end

  def about
  end

  def contact
  end
end
