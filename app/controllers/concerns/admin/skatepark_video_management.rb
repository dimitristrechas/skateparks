module Admin
  module SkateparkVideoManagement
    extend ActiveSupport::Concern
    include SkateparkPositionManagement

    private

    def attach_new_videos(skatepark)
      ordered_new_videos(skatepark).each do |youtube_url, position|
        skatepark.skatepark_videos.build(youtube_url: youtube_url, position: position)
      end
    end

    def ordered_new_videos(skatepark)
      positions = new_video_positions
      positions = fallback_new_video_positions(skatepark) if positions.empty?

      new_video_urls.zip(positions).filter_map do |youtube_url, position|
        next if youtube_url.blank? || position.blank?

        [youtube_url, position.to_i]
      end
    end

    def fallback_new_video_positions(skatepark)
      starting_position = existing_video_positions(skatepark).max.to_i + 1

      new_video_urls.each_index.map { |index| starting_position + index }
    end

    def existing_video_positions(skatepark)
      requested_positions(existing_video_attributes, skatepark.skatepark_videos)
    end

    def existing_video_attributes
      reorder_attributes(skatepark_attributes[:skatepark_videos_attributes])
    end

    def new_video_urls
      Array(skatepark_params[:new_video_urls]).map { |youtube_url| youtube_url.to_s.strip }
    end

    def new_video_positions
      Array(skatepark_params[:new_video_positions]).map { |position| position.presence&.to_i }
    end

    def reserve_existing_video_positions!(skatepark)
      reserve_existing_positions!(skatepark.skatepark_videos, existing_video_attributes)
    end
  end
end
