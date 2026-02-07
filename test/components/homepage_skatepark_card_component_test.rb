require 'test_helper'

class HomepageSkateparkCardComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers

  def setup
    @skatepark = create(:skatepark)
    @badge_type = :new
  end

  def test_renders_link_to_skatepark
    component = HomepageSkateparkCardComponent.new(skatepark: @skatepark, badge_type: @badge_type)

    with_request_url '/' do
      rendered = render_inline(component)
      assert_includes rendered.to_html, skatepark_path(@skatepark)
    end
  end

  def test_renders_skatepark_name
    component = HomepageSkateparkCardComponent.new(skatepark: @skatepark, badge_type: @badge_type)

    with_request_url '/' do
      rendered = render_inline(component)
      assert_match @skatepark.name, rendered.to_html
    end
  end

  def test_renders_photo_count
    component = HomepageSkateparkCardComponent.new(skatepark: @skatepark, badge_type: @badge_type)

    with_request_url '/' do
      rendered = render_inline(component)
      assert_match "#{@skatepark.images.size} #{I18n.t('photos')}", rendered.to_html
    end
  end

  def test_renders_cover_image_with_alt_text
    component = HomepageSkateparkCardComponent.new(skatepark: @skatepark, badge_type: @badge_type)

    with_request_url '/' do
      render_inline(component)
      assert_selector "img[alt='#{@skatepark.name} cover image']"
    end
  end

  def test_renders_new_badge_with_new_badge_type
    component = HomepageSkateparkCardComponent.new(skatepark: @skatepark, badge_type: :new)

    with_request_url '/' do
      rendered = render_inline(component)
      assert_match I18n.t(:new), rendered.to_html
    end
  end

  def test_renders_popular_badge_with_popular_badge_type
    component = HomepageSkateparkCardComponent.new(skatepark: @skatepark, badge_type: :popular)

    with_request_url '/' do
      rendered = render_inline(component)
      assert_match I18n.t(:popular), rendered.to_html
    end
  end
end
