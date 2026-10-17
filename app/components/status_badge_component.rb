# frozen_string_literal: true

class StatusBadgeComponent < ViewComponent::Base
  BASE_CLASSES = 'rounded px-2 py-1 text-xs font-medium'

  VARIANTS = {
    success: 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300',
    danger: 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300',
    neutral: 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300',
    warning: 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-300',
    info: 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-300',
  }.freeze

  STATUS_VARIANTS = {
    active: :success,
    banned: :danger,
    discarded: :neutral,
    published: :success,
    draft: :warning,
    archived: :neutral,
  }.freeze

  I18N_KEYS = {
    active: 'admin.users.active',
    banned: 'admin.users.banned',
    discarded: 'admin.users.discarded',
    published: 'admin.skateparks.statuses.published',
    draft: 'admin.skateparks.statuses.draft',
    archived: 'admin.skateparks.statuses.archived',
  }.freeze

  def initialize(status: nil, variant: nil, text: nil)
    super()
    @status = status&.to_sym
    @text = text
    @variant = resolve_variant(variant)

    raise ArgumentError, "unknown variant: #{@variant}" unless VARIANTS.key?(@variant)
    return if @text.present? || known_status?

    raise ArgumentError, "text is required unless status is one of: #{STATUS_VARIANTS.keys.join(', ')}"
  end

  private

  attr_reader :status, :variant, :text

  def resolve_variant(variant)
    return variant.to_sym if variant.present?
    return STATUS_VARIANTS[status] if known_status?

    raise ArgumentError, 'variant is required for a custom status'
  end

  def known_status?
    STATUS_VARIANTS.key?(status)
  end

  def badge_text
    return text if text.present?

    t(I18N_KEYS.fetch(status))
  end

  def badge_classes
    class_names(BASE_CLASSES, VARIANTS.fetch(variant))
  end
end
