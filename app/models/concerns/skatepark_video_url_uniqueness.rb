module SkateparkVideoUrlUniqueness
  extend ActiveSupport::Concern

  included do
    validate :unique_video_urls
  end

  private

  def unique_video_urls
    duplicate_video_urls.each do |youtube_url|
      errors.add(:skatepark_videos, :duplicate_video, youtube_url: youtube_url)
    end
  end

  def duplicate_video_urls
    nested_skatepark_videos.reject(&:rejected?)
                           .group_by { |skatepark_video| normalized_video_id(skatepark_video) }
                           .filter_map do |video_id, video_records|
      next if video_id.blank? || video_records.one?

      video_records.first.youtube_url.to_s.strip
    end
  end

  def nested_skatepark_videos
    skatepark_videos.reject(&:marked_for_destruction?).select do |skatepark_video|
      skatepark_video.youtube_url.present?
    end
  end

  def normalized_video_id(skatepark_video)
    skatepark_video.youtube_video_id.presence ||
      SkateparkVideo.extract_video_id(skatepark_video.youtube_url)
  end
end
