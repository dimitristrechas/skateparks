class HomepageSkateparkCardComponentPreview < ViewComponent::Preview
  # @label Latest
  def latest
    skatepark = Skatepark.published.with_attached_cover_image.with_attached_images.last
    render(HomepageSkateparkCardComponent.new(skatepark:, badge_type: :latest)) if skatepark
  end

  # @label Popular
  def popular
    skatepark = Skatepark.published.with_attached_cover_image.with_attached_images.first
    render(HomepageSkateparkCardComponent.new(skatepark:, badge_type: :popular)) if skatepark
  end
end
