module Admin
  module SkateparkVideoManagement
    extend ActiveSupport::Concern
    include SkateparkPositionManagement

    private

    def attach_new_videos(skatepark)
      ordered_new_items(new_video_urls, new_video_positions,
                        records: skatepark.skatepark_videos,
                        existing_attributes: existing_video_attributes).each do |youtube_url, position|
        skatepark.skatepark_videos.build(youtube_url: youtube_url, position: position, status: :active)
      end
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
