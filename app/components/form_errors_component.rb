# frozen_string_literal: true

class FormErrorsComponent < ViewComponent::Base
  def initialize(model:, heading: nil)
    super()
    @model = model
    @heading = heading
  end

  def render?
    model.errors.any?
  end

  private

  attr_reader :model, :heading

  def heading_text
    return heading if heading.present?

    t('form_errors.heading', count: model.errors.count)
  end

  def messages
    model.errors.full_messages
  end
end
