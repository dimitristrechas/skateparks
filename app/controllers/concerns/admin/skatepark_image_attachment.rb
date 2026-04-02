module Admin
  module SkateparkImageAttachment
    extend ActiveSupport::Concern
    include SkateparkPositionManagement

    private

    def attach_new_images(skatepark)
      ordered_new_images(skatepark).each do |image, position|
        skatepark_image = skatepark.skatepark_images.build(position: position)
        skatepark_image.image.attach(image)
      end
    end

    def ordered_new_images(skatepark)
      positions = new_image_positions
      positions = fallback_new_image_positions(skatepark) if positions.empty?

      new_images.zip(positions).filter_map do |image, position|
        next if image.blank? || position.blank?

        [image, position.to_i]
      end
    end

    def fallback_new_image_positions(skatepark)
      starting_position = existing_image_positions(skatepark).max.to_i + 1

      new_images.each_index.map { |index| starting_position + index }
    end

    def existing_image_positions(skatepark)
      requested_positions(existing_image_attributes, skatepark.skatepark_images)
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
