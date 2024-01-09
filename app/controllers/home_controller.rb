
class HomeController < ApplicationController
  def index
      @skateparks = Skatepark.all
      @locale = params["locale"]
    end
end
