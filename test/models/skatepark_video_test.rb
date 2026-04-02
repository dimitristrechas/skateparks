require 'test_helper'

class SkateparkVideoTest < ActiveSupport::TestCase
  def setup
    Rails.cache.clear
  end

  def test_requires_youtube_url_to_be_present
    skatepark_video = build(:skatepark_video, youtube_url: nil)

    assert_not skatepark_video.valid?
    assert_includes skatepark_video.errors[:youtube_url], "can't be blank"
  end

  def test_requires_position_to_be_a_positive_integer
    skatepark_video = build(:skatepark_video, position: 0)

    assert_not skatepark_video.valid?

    skatepark_video.position = -1

    assert_not skatepark_video.valid?

    skatepark_video.position = 1.5

    assert_not skatepark_video.valid?

    skatepark_video.position = 1

    assert_predicate skatepark_video, :valid?
  end

  def test_allows_negative_position_when_reserved_for_reordering
    skatepark_video = build(:skatepark_video, position: -1)
    skatepark_video.allow_negative_position = true

    assert_predicate skatepark_video, :valid?
  end

  def test_accepts_supported_youtube_url_formats
    supported_urls = {
      'https://www.youtube.com/watch?v=dQw4w9WgXcQ' => 'dQw4w9WgXcQ',
      'https://youtu.be/dQw4w9WgXcQ' => 'dQw4w9WgXcQ',
      'https://www.youtube.com/shorts/dQw4w9WgXcQ' => 'dQw4w9WgXcQ',
      'https://www.youtube.com/embed/dQw4w9WgXcQ' => 'dQw4w9WgXcQ',
      'https://www.youtube.com/v/dQw4w9WgXcQ' => 'dQw4w9WgXcQ',
      'https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ' => 'dQw4w9WgXcQ',
      'https://m.youtube.com/watch?v=dQw4w9WgXcQ&t=42s' => 'dQw4w9WgXcQ',
    }

    supported_urls.each do |youtube_url, video_id|
      skatepark_video = build(:skatepark_video, youtube_url: youtube_url)

      assert_predicate skatepark_video, :valid?, "#{youtube_url} should be valid"
      assert_equal video_id, skatepark_video.youtube_video_id
    end
  end

  def test_rejects_invalid_youtube_url_formats
    skatepark_video = build(:skatepark_video, youtube_url: 'https://example.com/watch?v=dQw4w9WgXcQ')

    assert_not skatepark_video.valid?
    assert_includes skatepark_video.errors[:youtube_url], 'must be a valid YouTube URL'
  end

  def test_requires_youtube_url_to_be_unique_per_skatepark
    skatepark = create(:skatepark)
    create(:skatepark_video, skatepark: skatepark, youtube_url: 'https://youtu.be/dQw4w9WgXcQ')

    duplicate_video = build(:skatepark_video, skatepark: skatepark, youtube_url: 'https://youtu.be/dQw4w9WgXcQ')

    assert_not duplicate_video.valid?
    assert_includes duplicate_video.errors[:youtube_url], 'has already been taken'
  end

  def test_allows_same_youtube_url_for_different_skateparks
    create(:skatepark_video, youtube_url: 'https://youtu.be/dQw4w9WgXcQ')

    duplicate_video = build(:skatepark_video, youtube_url: 'https://youtu.be/dQw4w9WgXcQ')

    assert_predicate duplicate_video, :valid?
  end

  def test_returns_embed_and_thumbnail_urls
    skatepark_video = build(:skatepark_video, youtube_url: 'https://youtu.be/dQw4w9WgXcQ')

    assert_equal 'https://www.youtube.com/embed/dQw4w9WgXcQ', skatepark_video.embed_url
    assert_equal 'https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg', skatepark_video.thumbnail_url
  end

  def test_updates_counter_cache_on_create_and_destroy
    skatepark = create(:skatepark)
    skatepark_video = nil

    assert_difference(-> { skatepark.reload.skatepark_videos_count }, 1) do
      skatepark_video = create(:skatepark_video, skatepark: skatepark)
    end

    assert_difference(-> { skatepark.reload.skatepark_videos_count }, -1) do
      skatepark_video.destroy!
    end
  end

  def test_clears_homepage_caches_when_saved_and_destroyed
    write_homepage_caches

    skatepark_video = create(:skatepark_video)

    assert_homepage_caches_cleared

    write_homepage_caches

    skatepark_video.destroy!

    assert_homepage_caches_cleared
  end

  private

  def write_homepage_caches
    Rails.cache.write('skateparks_latest', ['latest'])
    Rails.cache.write('skateparks_popular', ['popular'])
  end

  def assert_homepage_caches_cleared
    assert_nil Rails.cache.read('skateparks_latest')
    assert_nil Rails.cache.read('skateparks_popular')
  end
end
