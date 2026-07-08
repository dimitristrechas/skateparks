# frozen_string_literal: true

require 'test_helper'

class SiteAnnouncementTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  def test_valid_factory
    assert_predicate build(:site_announcement), :valid?
  end

  def test_requires_message_in_both_locales
    announcement = build(:site_announcement, message_en: nil, message_el: 'Test')

    assert_not announcement.valid?
    assert_includes announcement.errors[:message_en], "can't be blank"

    announcement.message_en = 'Test'
    announcement.message_el = nil

    assert_not announcement.valid?
    assert_includes announcement.errors[:message_el], "can't be blank"
  end

  def test_requires_positive_position
    announcement = build(:site_announcement, position: 0)

    assert_not announcement.valid?
    assert_includes announcement.errors[:position], 'must be greater than 0'
  end

  def test_validates_link_url_format
    announcement = build(:site_announcement, link_url: 'not a url')

    assert_not announcement.valid?
    assert_includes announcement.errors[:link_url], 'is invalid'

    announcement.link_url = '/about'

    assert_predicate announcement, :valid?

    announcement.link_url = 'https://example.com/news'

    assert_predicate announcement, :valid?
  end

  def test_rejects_protocol_relative_link_url
    announcement = build(:site_announcement, link_url: '//evil.com')

    assert_not announcement.valid?
    assert_includes announcement.errors[:link_url], 'is invalid'
  end

  def test_validates_ends_at_after_starts_at
    announcement = build(
      :site_announcement,
      starts_at: Time.zone.local(2026, 7, 10, 12),
      ends_at: Time.zone.local(2026, 7, 9, 12)
    )

    assert_not announcement.valid?
    assert_predicate announcement.errors[:ends_at], :any?
  end

  def test_visible_scope_includes_published_announcements_in_window
    travel_to Time.zone.local(2026, 7, 7, 12) do
      visible = create(:site_announcement, published: true)
      create(:site_announcement, :draft)
      create(:site_announcement, :scheduled_future)
      create(:site_announcement, :expired)

      assert_equal [visible], SiteAnnouncement.visible.to_a
    end
  end

  def test_visible_scope_respects_optional_schedule_boundaries
    travel_to Time.zone.local(2026, 7, 7, 12) do
      starting_now = create(
        :site_announcement,
        starts_at: Time.zone.local(2026, 7, 7, 12),
        ends_at: Time.zone.local(2026, 7, 8, 12)
      )
      create(
        :site_announcement,
        starts_at: Time.zone.local(2026, 7, 8, 0, 0, 1),
        ends_at: nil
      )

      assert_equal [starting_now], SiteAnnouncement.visible.to_a
    end
  end

  def test_visible_predicate_matches_scope
    travel_to Time.zone.local(2026, 7, 7, 12) do
      announcement = create(:site_announcement)

      assert_predicate announcement, :visible?

      announcement.update!(published: false)

      assert_not announcement.visible?
    end
  end

  def test_ordered_scope_sorts_by_position_then_id
    second = create(:site_announcement, position: 2, message_en: 'Second', message_el: 'Δεύτερη')
    first = create(:site_announcement, position: 1, message_en: 'First', message_el: 'Πρώτη')

    assert_equal [first, second], SiteAnnouncement.ordered.to_a
  end

  def test_dismiss_token_is_stable_when_only_position_changes
    announcement = create(:site_announcement, position: 1)
    original_token = announcement.dismiss_token

    announcement.update!(position: 2)

    assert_equal original_token, announcement.dismiss_token
  end

  def test_dismiss_token_changes_when_message_changes
    announcement = create(:site_announcement)
    original_token = announcement.dismiss_token

    announcement.update!(message_en: 'Updated announcement copy')

    assert_not_equal original_token, announcement.dismiss_token
  end
end
