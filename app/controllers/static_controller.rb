class StaticController < ApplicationController
    def index
        @skateparks = Skatepark.all
    end
end
