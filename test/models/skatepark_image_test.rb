require 'test_helper'

class SkateparkImageTest < ActiveSupport::TestCase
  def test_requires_image_to_be_present
    skatepark_image = build(:skatepark_image)
    skatepark_image.image = nil

    assert_not skatepark_image.save
  end

  def test_requires_position_to_be_present
    skatepark_image = build(:skatepark_image, position: nil)

    assert_not skatepark_image.save
  end

  def test_requires_position_to_be_a_positive_integer
    skatepark_image = build(:skatepark_image, position: 0)

    assert_not skatepark_image.valid?

    skatepark_image.position = -1

    assert_not skatepark_image.valid?

    skatepark_image.position = 1.5

    assert_not skatepark_image.valid?

    skatepark_image.position = 1

    assert_predicate skatepark_image, :valid?
  end

  def test_allows_negative_position_when_reserved_for_reordering
    skatepark_image = build(:skatepark_image, position: -1)
    skatepark_image.allow_negative_position = true

    assert_predicate skatepark_image, :valid?
  end

  def test_orders_images_by_position
    skatepark = create(:skatepark)
    first_image, second_image = skatepark.skatepark_images.to_a

    first_image.update!(position: 3)
    second_image.update!(position: 2)
    create(:skatepark_image, skatepark: skatepark, position: 1)

    assert_equal [1, 2, 3], skatepark.reload.skatepark_images.limit(3).pluck(:position)
  end
end
