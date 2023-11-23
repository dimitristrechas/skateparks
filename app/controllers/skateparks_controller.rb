class SkateparksController < ApplicationController
  before_action :set_skatepark, only: %i[ show ]

  # GET /skateparks or /skateparks.json
  def index
    @skateparks = Skatepark.all
  end

  # GET /skateparks/1 or /skateparks/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_skatepark
      @skatepark = Skatepark.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def skatepark_params
      params.require(:skatepark).permit(:name, :lat, :lng, images: [])
    end
end
