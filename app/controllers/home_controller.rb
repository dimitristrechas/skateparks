
class HomeController < ApplicationController
  def index
    @skateparks = Skatepark.all.order(created_at: :desc)
    @locale = params["locale"]
  end

  def about
  end

  def contact
  end
end
