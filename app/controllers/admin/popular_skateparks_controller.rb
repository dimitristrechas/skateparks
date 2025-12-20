module Admin
  class PopularSkateparksController < ApplicationController
    before_action :set_popular_skatepark, only: %i[update destroy]
    http_basic_authenticate_with name: Rails.application.credentials.dig(:admin, :username),
                                 password: Rails.application.credentials.dig(:admin, :password),
                                 unless: -> { Rails.env.development? }

    def index
      @popular_skateparks = PopularSkatepark.includes(:skatepark)
      @available_skateparks = available_skateparks
    end

    def create
      @popular_skatepark = PopularSkatepark.new(popular_skatepark_params)

      if @popular_skatepark.save
        redirect_to admin_popular_skateparks_url,
                    notice: t('admin.popular_skateparks.added_notice')
      else
        @popular_skateparks = PopularSkatepark.includes(:skatepark)
        @available_skateparks = available_skateparks

        render :index, status: :unprocessable_content
      end
    end

    def update
      if @popular_skatepark.update(popular_skatepark_params)
        redirect_to admin_popular_skateparks_url,
                    notice: t('admin.popular_skateparks.updated_notice')
      else
        @popular_skateparks = PopularSkatepark.includes(:skatepark)
        @available_skateparks = available_skateparks

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
      @popular_skatepark = PopularSkatepark.find(params[:id])
    end

    def popular_skatepark_params
      params.expect(popular_skatepark: %i[skatepark_id position])
    end

    def available_skateparks
      Skatepark.published
               .where.not(id: PopularSkatepark.select(:skatepark_id))
               .order(:name)
    end
  end
end
