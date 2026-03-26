module Admin
  class SkateparksController < BaseController
    before_action :set_skatepark, only: %i[show edit update destroy]

    # GET /skateparks or /skateparks.json
    def index
      @skateparks = Skatepark.i18n.order(:name)
    end

    # GET /skateparks/1 or /skateparks/1.json
    def show; end

    # GET /skateparks/new
    def new
      @skatepark = Skatepark.new
    end

    # GET /skateparks/1/edit
    def edit; end

    # POST /skateparks or /skateparks.json
    def create
      @skatepark = Skatepark.new(skatepark_params)

      respond_to do |format|
        if @skatepark.save
          format.html do
            redirect_to admin_skateparks_url,
                        notice: "Skatepark: #{@skatepark.name} was successfully created."
          end
          format.json { render :show, status: :created, location: @skatepark }
        else
          format.html { render :new, status: :unprocessable_content }
          format.json { render json: @skatepark.errors, status: :unprocessable_content }
        end
      end
    end

    # PATCH/PUT /skateparks/1 or /skateparks/1.json
    def update
      respond_to do |format|
        if @skatepark.update(skatepark_params)
          format.html do
            redirect_to admin_skateparks_url,
                        notice: "Skatepark: #{@skatepark.name} was successfully updated."
          end
          format.json { render :show, status: :ok, location: @skatepark }
        else
          format.html { render :edit, status: :unprocessable_content }
          format.json { render json: @skatepark.errors, status: :unprocessable_content }
        end
      end
    end

    # DELETE /skateparks/1 or /skateparks/1.json
    def destroy
      @skatepark.destroy!

      respond_to do |format|
        format.html do
          redirect_to admin_skateparks_url, notice: "Skatepark: #{@skatepark.name} was successfully destroyed."
        end
        format.json { head :no_content }
      end
    end

    def states
      country = ISO3166::Country[params[:country_code]]
      render json: country ? country.subdivisions : {}
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_skatepark
      @skatepark = Skatepark.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def skatepark_params
      params.expect(skatepark: [:name_el, :name_en, :lat, :lng, :cover_image, :description_el, :description_en,
                                :google_id, :status, :country_code, :state, { images: [] },])
    end
  end
end
