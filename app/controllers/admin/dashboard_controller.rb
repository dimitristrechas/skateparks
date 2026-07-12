module Admin
  class DashboardController < BaseController
    def index
      @pending_video_suggestions_count = SkateparkVideo.pending_review.count
      @visible_site_announcements_count = SiteAnnouncement.visible.count
    end
  end
end
