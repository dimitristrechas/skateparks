# frozen_string_literal: true

require 'test_helper'

class StatusBadgeComponentTest < ViewComponent::TestCase
  def test_renders_active_status_with_i18n_and_success_classes
    render_inline(StatusBadgeComponent.new(status: :active))

    assert_selector 'span', text: I18n.t('admin.users.active')
    assert_includes rendered_content, 'bg-green-100'
    assert_includes rendered_content, 'text-green-800'
    assert_includes rendered_content, 'dark:bg-green-900'
    assert_includes rendered_content, 'dark:text-green-300'
  end

  def test_renders_banned_status_with_danger_classes
    render_inline(StatusBadgeComponent.new(status: :banned))

    assert_selector 'span', text: I18n.t('admin.users.banned')
    assert_includes rendered_content, 'bg-red-100'
    assert_includes rendered_content, 'dark:text-red-300'
  end

  def test_renders_discarded_status_with_neutral_classes
    render_inline(StatusBadgeComponent.new(status: :discarded))

    assert_selector 'span', text: I18n.t('admin.users.discarded')
    assert_includes rendered_content, 'bg-gray-100'
    assert_includes rendered_content, 'dark:bg-gray-700'
    assert_includes rendered_content, 'dark:text-gray-300'
  end

  def test_renders_greek_copy_for_predefined_status
    I18n.with_locale(:el) do
      render_inline(StatusBadgeComponent.new(status: :banned))
    end

    assert_selector 'span', text: I18n.t('admin.users.banned', locale: :el)
  end

  def test_renders_published_status_with_success_classes
    render_inline(StatusBadgeComponent.new(status: :published))

    assert_selector 'span', text: I18n.t('admin.skateparks.statuses.published')
    assert_includes rendered_content, 'bg-green-100'
    assert_includes rendered_content, 'dark:text-green-300'
  end

  def test_renders_draft_status_with_warning_classes
    render_inline(StatusBadgeComponent.new(status: :draft))

    assert_selector 'span', text: I18n.t('admin.skateparks.statuses.draft')
    assert_includes rendered_content, 'bg-yellow-100'
    assert_includes rendered_content, 'dark:bg-yellow-900'
    assert_includes rendered_content, 'dark:text-yellow-300'
  end

  def test_renders_archived_status_with_neutral_classes
    render_inline(StatusBadgeComponent.new(status: :archived))

    assert_selector 'span', text: I18n.t('admin.skateparks.statuses.archived')
    assert_includes rendered_content, 'bg-gray-100'
    assert_includes rendered_content, 'dark:text-gray-300'
  end

  def test_renders_greek_copy_for_skatepark_status
    I18n.with_locale(:el) do
      render_inline(StatusBadgeComponent.new(status: :draft))
    end

    assert_selector 'span', text: I18n.t('admin.skateparks.statuses.draft', locale: :el)
  end

  def test_accepts_enum_string_status
    render_inline(StatusBadgeComponent.new(status: 'published'))

    assert_selector 'span', text: I18n.t('admin.skateparks.statuses.published')
    assert_includes rendered_content, 'bg-green-100'
  end

  def test_custom_text_overrides_i18n
    render_inline(StatusBadgeComponent.new(status: :active, text: 'Published'))

    assert_selector 'span', text: 'Published'
    assert_no_text I18n.t('admin.users.active')
  end

  def test_renders_warning_variant_with_custom_text
    render_inline(StatusBadgeComponent.new(variant: :warning, text: 'Draft'))

    assert_selector 'span', text: 'Draft'
    assert_includes rendered_content, 'bg-yellow-100'
    assert_includes rendered_content, 'text-yellow-800'
    assert_includes rendered_content, 'dark:bg-yellow-900'
    assert_includes rendered_content, 'dark:text-yellow-300'
  end

  def test_renders_info_variant
    render_inline(StatusBadgeComponent.new(variant: :info, text: 'Scheduled'))

    assert_includes rendered_content, 'bg-blue-100'
    assert_includes rendered_content, 'text-blue-800'
    assert_includes rendered_content, 'dark:bg-blue-900'
    assert_includes rendered_content, 'dark:text-blue-300'
  end

  def test_includes_base_classes
    render_inline(StatusBadgeComponent.new(status: :active))

    assert_includes rendered_content, 'rounded'
    assert_includes rendered_content, 'px-2'
    assert_includes rendered_content, 'py-1'
    assert_includes rendered_content, 'text-xs'
    assert_includes rendered_content, 'font-medium'
  end

  def test_variant_overrides_status_color
    render_inline(StatusBadgeComponent.new(status: :active, variant: :info, text: 'Live'))

    assert_includes rendered_content, 'bg-blue-100'
    assert_not_includes rendered_content, 'bg-green-100'
  end

  def test_accepts_string_status_and_variant
    render_inline(StatusBadgeComponent.new(status: 'discarded', variant: 'warning'))

    assert_selector 'span', text: I18n.t('admin.users.discarded')
    assert_includes rendered_content, 'bg-yellow-100'
  end

  def test_raises_for_unknown_variant
    error = assert_raises(ArgumentError) do
      StatusBadgeComponent.new(variant: :purple, text: 'Nope')
    end

    assert_match(/unknown variant/, error.message)
  end

  def test_raises_when_custom_status_has_no_variant
    assert_raises(ArgumentError) { StatusBadgeComponent.new(status: :suspended, text: 'Suspended') }
  end

  def test_raises_when_variant_has_no_text
    assert_raises(ArgumentError) { StatusBadgeComponent.new(variant: :success) }
  end
end
