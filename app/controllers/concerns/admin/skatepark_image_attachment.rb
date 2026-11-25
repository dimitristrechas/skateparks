module Admin
  module SkateparkImageAttachment
    extend ActiveSupport::Concern
    include SkateparkPositionManagement

    private

    def attach_new_images(skatepark)
      ordered_new_items(new_images, new_image_positions,
                        records: skatepark.skatepark_images,
                        existing_attributes: existing_image_attributes).each do |image, position|
        skatepark.skatepark_images.build(position: position).image.attach(image)
      end
    end

    def existing_image_attributes
      reorder_attributes(skatepark_attributes[:skatepark_images_attributes])
    end

    def new_images
      Array(skatepark_params[:new_images]).compact_blank
    end

    def new_image_positions
      Array(skatepark_params[:new_image_positions]).compact_blank.map(&:to_i)
    end

    def reserve_existing_image_positions!(skatepark)
      reserve_existing_positions!(skatepark.skatepark_images, existing_image_attributes)
    end
  end
end
