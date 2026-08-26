# frozen_string_literal: true

module Admin
  class SiteAnnouncementsController < BaseController
    before_action :set_site_announcement, only: %i[edit update destroy]

    def index
      @site_announcements = SiteAnnouncement.ordered.includes(:string_translations)
    end

    def new
      @site_announcement = SiteAnnouncement.new(position: next_position)
    end

    def edit; end

    def create
      @site_announcement = SiteAnnouncement.new(site_announcement_params)

      if persist_new_site_announcement
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
      @site_announcement = SiteAnnouncement.find(params.expect(:id))
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
      locked_next_position
    end

    def persist_new_site_announcement
      SiteAnnouncement.transaction do
        @site_announcement.position = locked_next_position
        saved = @site_announcement.save
        raise ActiveRecord::Rollback unless saved

        saved
      end
    end

    def locked_next_position
      SiteAnnouncement.lock.order(position: :desc).first&.position.to_i + 1
    end
  end
end
