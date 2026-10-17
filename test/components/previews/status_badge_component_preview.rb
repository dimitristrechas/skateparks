# frozen_string_literal: true

class StatusBadgeComponentPreview < ViewComponent::Preview
  def active
    render(StatusBadgeComponent.new(status: :active))
  end

  def banned
    render(StatusBadgeComponent.new(status: :banned))
  end

  def discarded
    render(StatusBadgeComponent.new(status: :discarded))
  end

  def published
    render(StatusBadgeComponent.new(status: :published))
  end

  def draft
    render(StatusBadgeComponent.new(status: :draft))
  end

  def archived
    render(StatusBadgeComponent.new(status: :archived))
  end

  def custom
    render(StatusBadgeComponent.new(variant: :warning, text: 'Draft'))
  end
end
