# frozen_string_literal: true

class CounterBubbleComponent < ViewComponent::Base
  def initialize(count:, label:)
    super()
    @count = count
    @label = label
  end

  private

  attr_reader :count, :label

  def bubble_classes
    'rounded-full bg-pink-600/85 px-2 py-0.5 text-sm font-medium text-white dark:bg-pink-600/65 ' \
      'min-w-6 text-center tabular-nums'
  end
end
