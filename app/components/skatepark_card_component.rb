class SkateparkCardComponent < ViewComponent::Base
  def initialize(skatepark:, badge_type:)
    super
    @skatepark = skatepark
    @badge_type = badge_type
  end

  private

  def rotation_class
    case @badge_type
    when :new
      'hover:rotate-5'
    when :popular
      'hover:-rotate-5'
    else
      ''
    end
  end
end
