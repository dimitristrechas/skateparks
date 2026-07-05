require 'cgi'
require 'uri'

class SkateparkVideo < ApplicationRecord # rubocop:disable Metrics/ClassLength
  include ReorderablePosition

  YOUTUBE_VIDEO_ID_REGEX = /\A[A-Za-z0-9_-]{11}\z/

  enum :status, { pending: 0, active: 1, rejected: 2 }

  belongs_to :skatepark, inverse_of: :skatepark_videos, touch: true
  belongs_to :proposed_skatepark, class_name: 'Skatepark', optional: true, inverse_of: :proposed_skatepark_videos

  scope :ordered, -> { order(:position, :id) }
  scope :active, -> { where(status: statuses[:active]) }
  scope :pending_review, -> { where(status: statuses[:pending]) }

  validates :youtube_url, presence: true, length: { maximum: 255 }
  validate :youtube_url_format
  validate :unique_youtube_video_id_per_skatepark, unless: :duplicate_url_reported_on_skatepark?
  validate :proposed_skatepark_immutable, on: :update

  before_validation :assign_youtube_video_id
  before_validation :prepare_non_active_position
  before_validation :assign_active_position_if_needed, if: lambda {
    active? && (new_record? || will_save_change_to_status?)
  }
  before_create :remove_stale_rejected_duplicates
  after_destroy :clear_homepage_caches_if_active
  after_save :clear_homepage_caches_if_active
  after_commit :sync_skatepark_active_videos_count, on: %i[create update destroy]

  def youtube_video_id
    self[:youtube_video_id].presence || self.class.extract_video_id(youtube_url)
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

  def self.next_active_position_for(skatepark)
    skatepark.skatepark_videos.active.maximum(:position).to_i + 1
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

  def prepare_non_active_position
    return if active?

    self.position = 0
    self.allow_negative_position = true
  end

  def assign_active_position_if_needed
    return if skatepark.blank?
    return if position.to_i.positive?

    self.position = self.class.next_active_position_for(skatepark)
    self.allow_negative_position = false
  end

  def assign_youtube_video_id
    self[:youtube_video_id] = self.class.extract_video_id(youtube_url)
  end

  def proposed_skatepark_immutable
    return unless proposed_skatepark_id_changed? && proposed_skatepark_id_was.present?

    errors.add(:proposed_skatepark_id, :immutable)
  end

  def youtube_url_format
    return if youtube_url.blank?
    return if youtube_video_id.present?

    errors.add(:youtube_url, :invalid_format)
  end

  def duplicate_url_reported_on_skatepark?
    return false if skatepark.blank? || youtube_video_id.blank?

    skatepark.errors.where(:skatepark_videos, :duplicate_video).any? do |error|
      self.class.extract_video_id(error.options[:youtube_url]) == youtube_video_id
    end
  end

  def unique_youtube_video_id_per_skatepark
    return if youtube_video_id.blank? || skatepark_id.blank?

    scope = self.class.where(skatepark_id: skatepark_id, youtube_video_id: youtube_video_id)
                .where(status: %i[pending active])
    scope = scope.where.not(id: id) if persisted?
    existing = scope.first
    return unless existing

    errors.add(:youtube_url, existing.active? ? :already_published : :already_pending)
  end

  def remove_stale_rejected_duplicates
    return if youtube_video_id.blank? || skatepark_id.blank?

    self.class.rejected.where(skatepark_id: skatepark_id, youtube_video_id: youtube_video_id).delete_all
  end

  def clear_homepage_caches_if_active
    was_active = saved_change_to_status? && status_before_last_save == 'active'
    return unless active? || was_active

    clear_homepage_caches
  end

  def clear_homepage_caches
    Rails.cache.delete(Skatepark.homepage_latest_cache_key)
    Rails.cache.delete(Skatepark.homepage_popular_cache_key)
  end

  def sync_skatepark_active_videos_count
    affected_skatepark_ids = [skatepark_id, skatepark_id_before_last_save].compact.uniq
    affected_skatepark_ids.each do |affected_skatepark_id|
      active_count = SkateparkVideo.active.where(skatepark_id: affected_skatepark_id).count
      Skatepark.where(id: affected_skatepark_id).update_all(skatepark_videos_count: active_count) # rubocop:disable Rails/SkipsModelValidations
    end
  end
end
