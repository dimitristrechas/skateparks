# frozen_string_literal: true

class HomepageSkateparkCardComponentPreview < ViewComponent::Preview
  def new_badge
    skatepark = sample_skatepark
    return unless skatepark

    render(HomepageSkateparkCardComponent.new(skatepark: skatepark, badge_type: :new))
  end

  def popular_badge
    skatepark = sample_skatepark
    return unless skatepark

    render(HomepageSkateparkCardComponent.new(skatepark: skatepark, badge_type: :popular))
  end

  private

  def sample_skatepark
    Skatepark.published.includes(:skatepark_images).first
  end
end
