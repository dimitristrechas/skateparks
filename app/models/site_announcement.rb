# frozen_string_literal: true

class SiteAnnouncement < ApplicationRecord
  extend Mobility

  include ReorderablePosition

  LINK_URL_PATTERN = %r{\A(/(?!/)[^\s]*|https?://[^\s]+)\z}

  translates :message, type: :string
  translates :link_label, type: :string

  scope :ordered, -> { order(position: :asc, id: :asc) }
  scope :published, -> { where(published: true) }
  scope :currently_scheduled, lambda { |at = Time.zone.now|
    where('(starts_at IS NULL OR starts_at <= ?) AND (ends_at IS NULL OR ends_at >= ?)', at, at)
  }
  scope :visible, -> { published.currently_scheduled.ordered }

  validates :message_en, presence: true
  validates :message_el, presence: true
  validates :link_url, format: { with: LINK_URL_PATTERN }, allow_blank: true
  validates :ends_at, comparison: { greater_than: :starts_at }, allow_nil: true,
                      if: -> { starts_at.present? && ends_at.present? }

  def visible?(at = Time.zone.now)
    published? &&
      (starts_at.nil? || starts_at <= at) &&
      (ends_at.nil? || ends_at >= at)
  end
end
