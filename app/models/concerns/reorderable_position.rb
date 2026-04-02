module ReorderablePosition
  extend ActiveSupport::Concern

  included do
    attr_accessor :allow_negative_position

    validates :position, presence: true, numericality: { only_integer: true }
    validate :position_must_be_positive, unless: :allow_negative_position?
  end

  private

  def allow_negative_position?
    allow_negative_position
  end

  def position_must_be_positive
    return if position.blank? || position.positive?

    errors.add(:position, :greater_than, count: 0)
  end
end
