require 'test_helper'

class SkateparkTest < ActiveSupport::TestCase
  def test_requires_name_to_be_present
    skatepark = build(:skatepark)
    skatepark.name = nil

    assert_not skatepark.save
  end

  def test_requires_cover_image_to_be_present
    skatepark = build(:skatepark)
    skatepark.cover_image = nil

    assert_not skatepark.save
  end

  def test_requires_lat_to_be_present
    skatepark = build(:skatepark)
    skatepark.lat = nil

    assert_not skatepark.save
  end

  def test_requires_lng_to_be_present
    skatepark = build(:skatepark)
    skatepark.lng = nil

    assert_not skatepark.save
  end

  def test_requires_description_to_be_present
    skatepark = build(:skatepark)
    skatepark.description = nil

    assert_not skatepark.save
  end

  def test_requires_at_least_2_images_to_be_present
    skatepark = build(:skatepark, skatepark_images_count: 1)

    assert_not skatepark.save
  end

  def test_rejects_duplicate_new_image_filenames
    skatepark = create(:skatepark)
    duplicate_image = skatepark.skatepark_images.build(position: 3)

    duplicate_image.image.attach(
      Rack::Test::UploadedFile.new(
        Rails.root.join('test/fixtures/files/sample_image1.jpg'),
        'image/jpeg'
      )
    )

    assert_not skatepark.valid?
    assert_includes skatepark.errors[:skatepark_images], 'sample_image1.jpg has already been uploaded'
  end

  def test_rejects_duplicate_video_urls
    skatepark = create(:skatepark)
    create(:skatepark_video, skatepark: skatepark, youtube_url: 'https://youtu.be/dQw4w9WgXcQ')
    skatepark.skatepark_videos.build(position: 2, youtube_url: 'https://youtu.be/dQw4w9WgXcQ')

    assert_not skatepark.valid?
    assert_includes skatepark.errors[:skatepark_videos], 'https://youtu.be/dQw4w9WgXcQ has already been added'
  end

  def test_requires_status_to_be_present_and_valid
    skatepark = build(:skatepark, status: nil)

    assert_not skatepark.save

    skatepark.status = :published

    assert skatepark.save
  end

  def test_generates_slug_based_on_name
    skatepark = build(:skatepark, name_en: 'Test Skatepark', name_el: 'Test Skatepark')
    skatepark.save

    assert_equal 'test-skatepark', skatepark.slug
  end

  def test_updates_slug_when_name_changes
    skatepark = create(:skatepark, name_en: 'Test Skatepark', name_el: 'Test Skatepark')
    skatepark.update(name_en: 'Updated Name')

    assert_equal 'updated-name', skatepark.slug
  end

  def test_returns_correct_format_in_to_param
    skatepark = create(:skatepark, :us_location,
                       name_en: 'Chicago Skate Park',
                       name_el: 'Chicago Skate Park',
                       state: 'IL',
                       lat: 41.8819,
                       lng: -87.6231)

    assert_equal "#{skatepark.id}-chicago-skate-park", skatepark.to_param
  end

  def test_supports_near_scope_from_geocoder
    assert_respond_to Skatepark, :near
  end

  def test_near_scope_returns_skateparks_within_radius
    nearby = create(:skatepark, lat: 37.98, lng: 23.73)
    faraway = create(:skatepark, lat: 40.63, lng: 22.94)

    results = Skatepark.near([37.97, 23.72], 5, units: :km)

    assert_includes results, nearby
    assert_not_includes results, faraway
  end

  def test_orders_skatepark_videos_by_position
    skatepark = create(:skatepark)

    create(:skatepark_video, skatepark: skatepark, position: 2, youtube_url: 'https://youtu.be/dQw4w9WgXcQ')
    create(:skatepark_video, skatepark: skatepark, position: 1, youtube_url: 'https://youtu.be/9bZkp7q19f0')

    assert_equal [1, 2], skatepark.reload.skatepark_videos.pluck(:position)
  end

  def test_accepts_nested_skatepark_video_attributes_for_destruction
    skatepark = create(:skatepark)
    skatepark_video = create(:skatepark_video, skatepark: skatepark)

    skatepark.assign_attributes(
      skatepark_videos_attributes: {
        '0' => { id: skatepark_video.id, _destroy: '1' },
      }
    )

    assert_predicate skatepark.skatepark_videos.find { |video|
      video.id == skatepark_video.id
    }, :marked_for_destruction?
  end
end
