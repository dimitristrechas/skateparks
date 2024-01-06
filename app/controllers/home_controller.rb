
class HomeController < ApplicationController

    def index
        @skateparks = Skatepark.all
    end
end
