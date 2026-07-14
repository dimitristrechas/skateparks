module Admin
  class SkateparksController < BaseController
    include SkateparkImageAttachment
    include SkateparkVideoManagement

    before_action :set_skatepark, only: %i[show edit update destroy]

    # GET /skateparks or /skateparks.json
    def index
      @skateparks = Skatepark.i18n.order(:name).includes(:skatepark_images)
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
      @skatepark = Skatepark.new(skatepark_attributes)
      attach_new_images(@skatepark)
      attach_new_videos(@skatepark)

      respond_to do |format|
        if @skatepark.save
          format.html do
            redirect_to admin_skateparks_url,
                        notice: t('admin.skateparks.created_notice', name: @skatepark.name)
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
        if save_skatepark_update
          format.html do
            redirect_to admin_skateparks_url,
                        notice: t('admin.skateparks.updated_notice', name: @skatepark.name)
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
          redirect_to admin_skateparks_url, notice: t('admin.skateparks.destroyed_notice', name: @skatepark.name)
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
      @skatepark = Skatepark.includes(
        :skatepark_videos,
        cover_image_attachment: :blob,
        skatepark_images: { image_attachment: :blob }
      ).find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def skatepark_params
      @skatepark_params ||= params.expect(skatepark: [:name_el, :name_en, :lat, :lng, :cover_image, :description_el,
                                                      :description_en, :meta_title_el, :meta_title_en,
                                                      :meta_description_el, :meta_description_en,
                                                      :google_id, :status, :country_code, :state,
                                                      { new_images: [] },
                                                      { new_image_positions: [] },
                                                      { new_video_urls: [] },
                                                      { new_video_positions: [] },
                                                      { skatepark_images_attributes: [%i[id position _destroy]] },
                                                      {
                                                        skatepark_videos_attributes: [%i[id position status _destroy]],
                                                      },])
    end

    def skatepark_attributes
      skatepark_params.except(:new_images, :new_image_positions, :new_video_urls, :new_video_positions)
    end

    def save_skatepark_update
      save_succeeded = false

      ActiveRecord::Base.transaction do
        reserve_existing_image_positions!(@skatepark)
        reserve_existing_video_positions!(@skatepark)
        @skatepark.assign_attributes(skatepark_attributes)
        attach_new_images(@skatepark)
        attach_new_videos(@skatepark)
        save_succeeded = @skatepark.save

        raise ActiveRecord::Rollback unless save_succeeded
      end

      save_succeeded
    end
  end
end
