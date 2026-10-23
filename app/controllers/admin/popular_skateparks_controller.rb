module Admin
  class PopularSkateparksController < BaseController
    before_action :set_popular_skatepark, only: %i[update destroy]

    def index
      @popular_skatepark = PopularSkatepark.new
      load_popular_skateparks
    end

    def create
      @popular_skatepark = PopularSkatepark.new(popular_skatepark_params)

      if @popular_skatepark.save
        redirect_to admin_popular_skateparks_url,
                    notice: t('admin.popular_skateparks.added_notice')
      else
        load_popular_skateparks

        render :index, status: :unprocessable_content
      end
    end

    def update
      if @popular_skatepark.update(popular_skatepark_params)
        redirect_to admin_popular_skateparks_url,
                    notice: t('admin.popular_skateparks.updated_notice')
      else
        load_popular_skateparks

        render :index, status: :unprocessable_content
      end
    end

    def destroy
      @popular_skatepark.destroy!
      redirect_to admin_popular_skateparks_url,
                  notice: t('admin.popular_skateparks.removed_notice')
    end

    private

    def set_popular_skatepark
      @popular_skatepark = PopularSkatepark.find(params.expect(:id))
    end

    def popular_skatepark_params
      params.expect(popular_skatepark: %i[skatepark_id position])
    end

    def load_popular_skateparks
      @popular_skateparks = PopularSkatepark.includes(skatepark: :string_translations)
    end
  end
end
