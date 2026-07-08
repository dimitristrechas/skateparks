# frozen_string_literal: true

module Admin
  class SiteAnnouncementsController < BaseController
    before_action :set_site_announcement, only: %i[edit update destroy]

    def index
      @site_announcements = SiteAnnouncement.ordered
    end

    def new
      @site_announcement = SiteAnnouncement.new(position: next_position)
    end

    def edit; end

    def create
      @site_announcement = SiteAnnouncement.new(site_announcement_params)

      if @site_announcement.save
        redirect_to admin_site_announcements_url, notice: t('admin.site_announcements.created_notice')
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @site_announcement.update(site_announcement_params)
        redirect_to admin_site_announcements_url, notice: t('admin.site_announcements.updated_notice')
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @site_announcement.destroy!
      redirect_to admin_site_announcements_url, notice: t('admin.site_announcements.destroyed_notice')
    end

    private

    def set_site_announcement
      @site_announcement = SiteAnnouncement.find(params[:id])
    end

    def site_announcement_params
      params.expect(
        site_announcement: %i[
          message_en
          message_el
          link_label_en
          link_label_el
          link_url
          published
          starts_at
          ends_at
          position
        ]
      )
    end

    def next_position
      SiteAnnouncement.maximum(:position).to_i + 1
    end
  end
end
