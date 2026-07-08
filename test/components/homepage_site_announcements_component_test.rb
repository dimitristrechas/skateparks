# frozen_string_literal: true

require 'test_helper'

class HomepageSiteAnnouncementsComponentTest < ViewComponent::TestCase
  def test_does_not_render_without_announcements
    render_inline(HomepageSiteAnnouncementsComponent.new(announcements: []))

    assert_no_selector '[role="region"]'
  end

  def test_renders_region_with_aria_label
    announcement = build_stubbed(:site_announcement)

    I18n.with_locale(:en) do
      render_inline(HomepageSiteAnnouncementsComponent.new(announcements: [announcement]))

      assert_selector "[role='region'][aria-label='#{I18n.t('home.site_announcements.region_label')}']"
    end
  end

  def test_renders_message_in_current_locale
    announcement = build_stubbed(:site_announcement, message_en: 'English news', message_el: 'Ελληνικά νέα')

    I18n.with_locale(:el) do
      render_inline(HomepageSiteAnnouncementsComponent.new(announcements: [announcement]))

      assert_text 'Ελληνικά νέα'
    end
  end

  def test_renders_multiple_announcements
    announcements = [
      build_stubbed(:site_announcement, message_en: 'First'),
      build_stubbed(:site_announcement, message_en: 'Second'),
    ]

    render_inline(HomepageSiteAnnouncementsComponent.new(announcements: announcements))

    assert_selector 'article', count: 2
    assert_text 'First'
    assert_text 'Second'
  end

  def test_renders_optional_link
    announcement = build_stubbed(
      :site_announcement,
      :with_link,
      message_en: 'News with link'
    )

    render_inline(HomepageSiteAnnouncementsComponent.new(announcements: [announcement]))

    assert_selector "a[href='/about']", text: 'Learn more'
  end

  def test_renders_dismiss_button_and_stimulus_wiring
    announcement = build_stubbed(:site_announcement, id: 42)

    I18n.with_locale(:en) do
      render_inline(HomepageSiteAnnouncementsComponent.new(announcements: [announcement]))

      assert_selector '[data-controller="site-announcements"]'
      assert_selector '[data-site-announcements-target="item"][data-announcement-id="42"]'
      assert_selector '[data-dismiss-token]'
      assert_selector "button[aria-label='#{I18n.t('home.site_announcements.dismiss')}']"
      assert_selector 'button[data-action="click->site-announcements#dismiss"]'
    end
  end

  def test_renders_article_with_aria_labelledby_message
    announcement = build_stubbed(:site_announcement, id: 7, message_en: 'Important news')

    render_inline(HomepageSiteAnnouncementsComponent.new(announcements: [announcement]))

    assert_selector 'article[aria-labelledby="site-announcement-message-7"]'
    assert_selector '#site-announcement-message-7', text: 'Important news'
  end

  def test_wrapper_visible_without_hidden_class_for_no_js_fallback
    announcement = build_stubbed(:site_announcement)

    render_inline(HomepageSiteAnnouncementsComponent.new(announcements: [announcement]))

    assert_selector '[role="region"]'
    assert_no_selector '[role="region"].hidden'
  end

  def test_renders_inline_boot_script_for_dismiss_filtering
    announcement = build_stubbed(:site_announcement)

    render_inline(HomepageSiteAnnouncementsComponent.new(announcements: [announcement]))

    assert_selector 'script', visible: :all
    assert_includes rendered_content, 'skateparks.site_announcement.dismissed.'
  end
end
