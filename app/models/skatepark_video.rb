require 'cgi'
require 'uri'

class SkateparkVideo < ApplicationRecord
  include ReorderablePosition

  YOUTUBE_VIDEO_ID_REGEX = /\A[\w-]{11}\z/

  belongs_to :skatepark, counter_cache: true, inverse_of: :skatepark_videos, touch: true

  scope :ordered, -> { order(:position, :id) }

  validates :youtube_url, presence: true
  validates :youtube_url, uniqueness: { scope: :skatepark_id }, unless: :duplicate_url_reported_on_skatepark?
  validate :youtube_url_format

  after_destroy :clear_homepage_caches
  after_save :clear_homepage_caches

  def youtube_video_id
    self.class.extract_video_id(youtube_url)
  end

  def embed_url
    return if youtube_video_id.blank?

    "https://www.youtube.com/embed/#{youtube_video_id}"
  end

  def thumbnail_url
    return if youtube_video_id.blank?

    "https://img.youtube.com/vi/#{youtube_video_id}/hqdefault.jpg"
  end

  def self.extract_video_id(url)
    uri = parsed_video_uri(url)
    return unless uri

    candidate = candidate_video_id_for(uri)

    candidate if candidate&.match?(YOUTUBE_VIDEO_ID_REGEX)
  end

  def self.extract_youtube_dot_com_video_id(path_segments, query)
    case path_segments.first
    when 'watch'
      CGI.parse(query.to_s)['v']&.first
    when 'shorts', 'embed', 'v'
      path_segments.second
    end
  end
  private_class_method :extract_youtube_dot_com_video_id

  def self.parsed_video_uri(url)
    uri = URI.parse(url.to_s)
    return if uri.scheme.blank? || uri.host.blank?

    uri
  rescue URI::InvalidURIError
    nil
  end
  private_class_method :parsed_video_uri

  def self.candidate_video_id_for(uri)
    path_segments = uri.path.to_s.split('/').compact_blank

    case normalized_video_host(uri)
    when 'youtu.be'
      path_segments.first
    when 'youtube.com', 'm.youtube.com'
      extract_youtube_dot_com_video_id(path_segments, uri.query)
    when 'youtube-nocookie.com'
      path_segments.first == 'embed' ? path_segments.second : nil
    end
  end
  private_class_method :candidate_video_id_for

  def self.normalized_video_host(uri)
    uri.host.downcase.delete_prefix('www.')
  end
  private_class_method :normalized_video_host

  private

  def youtube_url_format
    return if youtube_url.blank? || youtube_video_id.present?

    errors.add(:youtube_url, :invalid_format)
  end

  def duplicate_url_reported_on_skatepark?
    return false if skatepark.blank? || normalized_youtube_url.blank?

    skatepark.errors.where(:skatepark_videos, :duplicate_video).any? do |error|
      error.options[:youtube_url].to_s == normalized_youtube_url
    end
  end

  def clear_homepage_caches
    Rails.cache.delete('skateparks_latest')
    Rails.cache.delete('skateparks_popular')
  end

  def normalized_youtube_url
    youtube_url.to_s.strip
  end
end
