class SkateparksController < ApplicationController
  before_action :set_skatepark, only: %i[ show edit update destroy ]

  # GET /skateparks or /skateparks.json
  def index
    @skateparks = Skatepark.all
  end

  # GET /skateparks/1 or /skateparks/1.json
  def show
  end

  # GET /skateparks/new
  def new
    @skatepark = Skatepark.new
  end

  # GET /skateparks/1/edit
  def edit
  end

  # POST /skateparks or /skateparks.json
  def create
    @skatepark = Skatepark.new(skatepark_params)

    respond_to do |format|
      if @skatepark.save
        format.html { redirect_to skatepark_url(@skatepark), notice: "Skatepark was successfully created." }
        format.json { render :show, status: :created, location: @skatepark }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @skatepark.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /skateparks/1 or /skateparks/1.json
  def update
    respond_to do |format|
      if @skatepark.update(skatepark_params)
        format.html { redirect_to skatepark_url(@skatepark), notice: "Skatepark was successfully updated." }
        format.json { render :show, status: :ok, location: @skatepark }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @skatepark.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /skateparks/1 or /skateparks/1.json
  def destroy
    @skatepark.destroy!

    respond_to do |format|
      format.html { redirect_to skateparks_url, notice: "Skatepark was successfully destroyed." }
      format.json { head :no_content }
    end
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
