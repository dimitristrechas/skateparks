# frozen_string_literal: true

class HomepageSiteAnnouncementsComponentPreview < ViewComponent::Preview
  def default
    render(HomepageSiteAnnouncementsComponent.new(announcements: sample_announcements))
  end

  def with_link
    announcement = SiteAnnouncement.new(
      id: 1,
      message_en: 'New skateparks added across Greece.',
      message_el: 'Νέα skateparks σε όλη την Ελλάδα.',
      link_url: '/about',
      link_label_en: 'Learn more',
      link_label_el: 'Μάθετε περισσότερα',
      published: true
    )

    render(HomepageSiteAnnouncementsComponent.new(announcements: [announcement]))
  end

  private

  def sample_announcements
    [
      SiteAnnouncement.new(
        id: 1,
        message_en: 'Welcome to the updated Skateparks directory.',
        message_el: 'Καλώς ήρθατε στον ενημερωμένο κατάλογο Skateparks.',
        published: true
      ),
      SiteAnnouncement.new(
        id: 2,
        message_en: 'Share your local park photos with the community.',
        message_el: 'Μοιραστείτε φωτογραφίες του τοπικού πάρκου με την κοινότητα.',
        published: true
      ),
    ]
  end
end
