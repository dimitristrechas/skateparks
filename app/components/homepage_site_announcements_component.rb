# frozen_string_literal: true

class HomepageSiteAnnouncementsComponent < ViewComponent::Base
  DISMISSAL_KEY_PREFIX = 'skateparks.site_announcement.dismissed.'

  def initialize(announcements: nil)
    super()
    @announcements = announcements || SiteAnnouncement.visible.includes(:string_translations).to_a
  end

  def render?
    @announcements.any?
  end

  def link_label_for(announcement)
    announcement.link_label.presence || t('home.site_announcements.read_more')
  end

  def external_link?(url)
    url.start_with?('http://', 'https://', '//')
  end

  def dismissal_key_prefix
    DISMISSAL_KEY_PREFIX
  end

  def dismiss_label_for(announcement)
    t('home.site_announcements.dismiss_named', message: announcement.message)
  end

  def region_heading_id
    'site-announcements-heading'
  end

  def region_id
    'site-announcements-region'
  end

  def message_id_for(announcement)
    "site-announcement-message-#{announcement.id}"
  end
end
