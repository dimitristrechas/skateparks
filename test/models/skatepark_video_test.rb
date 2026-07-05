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
    skatepark_video = create(:skatepark_video)

    skatepark_video.position = 0
    skatepark_video.allow_negative_position = false

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
    assert_includes duplicate_video.errors[:youtube_url],
                    I18n.t('activerecord.errors.models.skatepark_video.attributes.youtube_url.already_published')
  end

  def test_rejects_duplicate_video_id_from_different_url_format
    skatepark = create(:skatepark)
    create(:skatepark_video, skatepark: skatepark, youtube_url: 'https://youtu.be/dQw4w9WgXcQ')

    duplicate_video = build(
      :skatepark_video,
      skatepark: skatepark,
      youtube_url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'
    )

    assert_not duplicate_video.valid?
    assert_includes duplicate_video.errors[:youtube_url],
                    I18n.t('activerecord.errors.models.skatepark_video.attributes.youtube_url.already_published')
    assert_equal 'dQw4w9WgXcQ', duplicate_video.youtube_video_id
  end

  def test_rejects_youtube_url_longer_than_255_characters
    skatepark_video = build(:skatepark_video, youtube_url: "https://youtu.be/#{'a' * 250}")

    assert_not skatepark_video.valid?
    assert_includes skatepark_video.errors[:youtube_url], 'is too long (maximum is 255 characters)'
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

  def test_updates_counter_cache_for_active_videos_only
    skatepark = create(:skatepark)
    skatepark_video = nil

    assert_difference(-> { skatepark.reload.skatepark_videos_count }, 1) do
      skatepark_video = create(:skatepark_video, skatepark: skatepark)
    end

    assert_no_difference(-> { skatepark.reload.skatepark_videos_count }) do
      create(:skatepark_video, :pending, skatepark: skatepark)
    end

    assert_difference(-> { skatepark.reload.skatepark_videos_count }, -1) do
      skatepark_video.destroy!
    end
  end

  def test_pending_video_defaults_to_pending_status
    skatepark_video = build(:skatepark_video, :pending)

    assert_predicate skatepark_video, :valid?
    assert_predicate skatepark_video, :pending?
    assert_equal 0, skatepark_video.position
  end

  def test_rejected_url_can_be_resubmitted_for_same_skatepark
    skatepark = create(:skatepark)
    create(:skatepark_video, :rejected, skatepark: skatepark, youtube_url: 'https://youtu.be/dQw4w9WgXcQ')

    duplicate_video = build(:skatepark_video, :pending, skatepark: skatepark, youtube_url: 'https://youtu.be/dQw4w9WgXcQ')

    assert_predicate duplicate_video, :valid?
  end

  def test_pending_duplicate_reports_clear_error_message
    skatepark = create(:skatepark)
    create(:skatepark_video, :pending, skatepark: skatepark, youtube_url: 'https://youtu.be/dQw4w9WgXcQ')

    duplicate_video = build(:skatepark_video, :pending, skatepark: skatepark, youtube_url: 'https://youtu.be/dQw4w9WgXcQ')

    assert_not duplicate_video.valid?
    assert_includes duplicate_video.errors[:youtube_url],
                    I18n.t('activerecord.errors.models.skatepark_video.attributes.youtube_url.already_pending')
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
    Rails.cache.write(Skatepark.homepage_latest_cache_key, ['latest'])
    Rails.cache.write(Skatepark.homepage_popular_cache_key, ['popular'])
  end

  def assert_homepage_caches_cleared
    assert_nil Rails.cache.read(Skatepark.homepage_latest_cache_key)
    assert_nil Rails.cache.read(Skatepark.homepage_popular_cache_key)
  end
end
