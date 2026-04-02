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
    active_skatepark_videos
      .group_by { |skatepark_video| normalized_video_url(skatepark_video) }
      .filter_map do |normalized_url, video_records|
        next if video_records.one?

        normalized_url
      end
  end

  def active_skatepark_videos
    skatepark_videos.reject(&:marked_for_destruction?).select do |skatepark_video|
      skatepark_video.youtube_url.present?
    end
  end

  def normalized_video_url(skatepark_video)
    skatepark_video.youtube_url.to_s.strip
  end
end
