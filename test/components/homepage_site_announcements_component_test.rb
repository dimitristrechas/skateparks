# frozen_string_literal: true

require 'test_helper'

class HomepageSiteAnnouncementsComponentTest < ViewComponent::TestCase
  def test_does_not_render_without_announcements
    render_inline(HomepageSiteAnnouncementsComponent.new(announcements: []))

    assert_no_selector '[role="region"]'
  end

  def test_renders_region_with_heading
    announcement = build_stubbed(:site_announcement)

    I18n.with_locale(:en) do
      render_inline(HomepageSiteAnnouncementsComponent.new(announcements: [announcement]))

      assert_selector "[role='region'][aria-labelledby='site-announcements-heading']"
      assert_selector '#site-announcements-region[role="region"]'
      assert_selector 'h2#site-announcements-heading', text: 'News'
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

    I18n.with_locale(:en) do
      render_inline(HomepageSiteAnnouncementsComponent.new(announcements: announcements))

      assert_selector 'article', count: 2
      assert_text 'First'
      assert_text 'Second'
      assert_selector "button[aria-label='#{I18n.t('home.site_announcements.dismiss_named', message: 'First')}']"
      assert_selector "button[aria-label='#{I18n.t('home.site_announcements.dismiss_named', message: 'Second')}']"
    end
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
    announcement = build_stubbed(:site_announcement, id: 42, message_en: 'Park hours updated')
    dismiss_label = I18n.t('home.site_announcements.dismiss_named', message: 'Park hours updated')

    I18n.with_locale(:en) do
      render_inline(HomepageSiteAnnouncementsComponent.new(announcements: [announcement]))

      assert_selector '[data-controller="site-announcements"]'
      assert_selector '[data-site-announcements-target="item"][data-announcement-id="42"]'
      assert_selector '[data-dismiss-token]'
      assert_selector "button[aria-label='#{dismiss_label}']"
      assert_selector 'button[data-site-announcements-dismiss-button]'
    end
  end

  def test_dismiss_button_does_not_use_stimulus_click_action
    announcement = build_stubbed(:site_announcement)

    render_inline(HomepageSiteAnnouncementsComponent.new(announcements: [announcement]))

    assert_no_selector 'button[data-action*="site-announcements#dismiss"]'
  end

  def test_renders_article_with_aria_labelledby_message
    announcement = build_stubbed(:site_announcement, id: 7, message_en: 'Important news')

    render_inline(HomepageSiteAnnouncementsComponent.new(announcements: [announcement]))

    assert_selector 'article[aria-labelledby="site-announcement-message-7"]'
    assert_selector '#site-announcement-message-7', text: 'Important news'
  end

  def test_renders_dismiss_key_prefix_on_region
    announcement = build_stubbed(:site_announcement)

    render_inline(HomepageSiteAnnouncementsComponent.new(announcements: [announcement]))

    assert_selector "[data-dismiss-key-prefix='#{HomepageSiteAnnouncementsComponent::DISMISSAL_KEY_PREFIX}']"
  end

  def test_wrapper_visible_without_hidden_class
    announcement = build_stubbed(:site_announcement)

    render_inline(HomepageSiteAnnouncementsComponent.new(announcements: [announcement]))

    assert_selector '[role="region"]'
    assert_no_selector '[role="region"].hidden'
  end

  def test_renders_dismiss_fallback_module_script
    announcement = build_stubbed(:site_announcement)

    render_inline(HomepageSiteAnnouncementsComponent.new(announcements: [announcement]))

    assert_selector 'script[type="module"]', visible: :all, count: 1
    assert_includes rendered_content, 'initializeSiteAnnouncements'
    assert_includes rendered_content, 'site_announcement_dismissals'
    assert_includes rendered_content, 'getElementById("site-announcements-region")'
    assert_not_includes rendered_content, 'currentScript'
  end
end
