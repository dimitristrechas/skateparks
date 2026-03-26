class HomepageSkateparkCardComponent < ViewComponent::Base
  def initialize(skatepark:, badge_type:)
    super()
    @skatepark = skatepark
    @badge_type = badge_type
  end
end
