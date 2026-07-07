class AddVideoSuggestionSupportToSkateparkVideos < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  POSITION_INDEX_NAME = 'index_skatepark_videos_on_skatepark_id_and_position'.freeze
  ACTIVE_POSITION_INDEX_NAME = 'index_skatepark_videos_on_skatepark_id_and_position_active'.freeze
  YOUTUBE_URL_INDEX = 'index_skatepark_videos_on_skatepark_id_and_youtube_url'.freeze
  VIDEO_ID_INDEX = 'index_skatepark_videos_on_skatepark_id_and_youtube_video_id'.freeze

  def up
    add_status_column!
    add_proposed_skatepark_reference!
    add_youtube_video_id_column!
    backfill_active_status!
    backfill_youtube_video_ids!
    remove_unparseable_youtube_urls!
    deduplicate_youtube_video_ids!
    make_youtube_video_id_not_null!
    replace_position_index!

    remove_index :skatepark_videos, name: YOUTUBE_URL_INDEX, algorithm: :concurrently if index_exists?(
      :skatepark_videos, name: YOUTUBE_URL_INDEX
    )

    unless index_exists?(:skatepark_videos, %i[skatepark_id youtube_video_id], name: VIDEO_ID_INDEX)
      add_index :skatepark_videos, %i[skatepark_id youtube_video_id],
                unique: true,
                where: 'status IN (0, 1)',
                name: VIDEO_ID_INDEX,
                algorithm: :concurrently
    end

    recount_active_video_counters!
  end

  def down
    remove_index :skatepark_videos, name: VIDEO_ID_INDEX, algorithm: :concurrently if index_exists?(
      :skatepark_videos, name: VIDEO_ID_INDEX
    )

    unless index_exists?(:skatepark_videos, %i[skatepark_id youtube_url], name: YOUTUBE_URL_INDEX)
      add_index :skatepark_videos, %i[skatepark_id youtube_url],
                unique: true,
                name: YOUTUBE_URL_INDEX,
                algorithm: :concurrently
    end

    remove_index :skatepark_videos, name: ACTIVE_POSITION_INDEX_NAME, algorithm: :concurrently if index_exists?(
      :skatepark_videos, name: ACTIVE_POSITION_INDEX_NAME
    )

    unless index_exists?(:skatepark_videos, name: POSITION_INDEX_NAME)
      add_index :skatepark_videos, %i[skatepark_id position],
                unique: true,
                name: POSITION_INDEX_NAME,
                algorithm: :concurrently
    end

    remove_reference :skatepark_videos, :proposed_skatepark if column_exists?(:skatepark_videos, :proposed_skatepark_id)
    remove_column :skatepark_videos, :youtube_video_id if column_exists?(:skatepark_videos, :youtube_video_id)
    remove_column :skatepark_videos, :status if column_exists?(:skatepark_videos, :status)
  end

  private

  def add_status_column!
    return if column_exists?(:skatepark_videos, :status)

    add_column :skatepark_videos, :status, :integer, default: 0, null: false
  end

  def add_proposed_skatepark_reference!
    return if column_exists?(:skatepark_videos, :proposed_skatepark_id)

    add_reference :skatepark_videos, :proposed_skatepark, index: false, foreign_key: false
    add_index :skatepark_videos, :proposed_skatepark_id,
              name: 'index_skatepark_videos_on_proposed_skatepark_id',
              algorithm: :concurrently
    add_foreign_key :skatepark_videos, :skateparks,
                    column: :proposed_skatepark_id,
                    validate: false
    validate_foreign_key :skatepark_videos, column: :proposed_skatepark_id
  end

  def add_youtube_video_id_column!
    return if column_exists?(:skatepark_videos, :youtube_video_id)

    add_column :skatepark_videos, :youtube_video_id, :string, limit: 11
  end

  def backfill_active_status!
    safety_assured do
      execute <<~SQL.squish
        UPDATE skatepark_videos SET status = 1
      SQL
    end
  end

  def backfill_youtube_video_ids!
    SkateparkVideo.reset_column_information

    SkateparkVideo.find_each do |skatepark_video|
      video_id = SkateparkVideo.extract_video_id(skatepark_video.youtube_url)
      next if video_id.blank?

      skatepark_video.update_column(:youtube_video_id, video_id)
    end
  end

  def remove_unparseable_youtube_urls!
    safety_assured do
      execute <<~SQL.squish
        DELETE FROM skatepark_videos WHERE youtube_video_id IS NULL
      SQL
    end
  end

  def make_youtube_video_id_not_null!
    column = connection.columns(:skatepark_videos).find { |entry| entry.name == 'youtube_video_id' }
    return if column.blank? || column.null == false

    safety_assured do
      change_column_null :skatepark_videos, :youtube_video_id, false
    end
  end

  def replace_position_index!
    if index_exists?(:skatepark_videos, %i[skatepark_id position], name: POSITION_INDEX_NAME)
      remove_index :skatepark_videos, name: POSITION_INDEX_NAME, algorithm: :concurrently
    end

    return if index_exists?(:skatepark_videos, %i[skatepark_id position], name: ACTIVE_POSITION_INDEX_NAME)

    add_index :skatepark_videos, %i[skatepark_id position],
              unique: true,
              where: 'status = 1',
              name: ACTIVE_POSITION_INDEX_NAME,
              algorithm: :concurrently
  end

  def deduplicate_youtube_video_ids!
    safety_assured do
      execute <<~SQL.squish
        DELETE FROM skatepark_videos
        WHERE id IN (
          SELECT id
          FROM (
            SELECT id,
              ROW_NUMBER() OVER (
                PARTITION BY skatepark_id, youtube_video_id
                ORDER BY
                  CASE status WHEN 1 THEN 0 WHEN 0 THEN 1 WHEN 2 THEN 2 END,
                  id ASC
              ) AS row_number
            FROM skatepark_videos
            WHERE youtube_video_id IS NOT NULL
          ) ranked_videos
          WHERE row_number > 1
        )
      SQL
    end
  end

  def recount_active_video_counters!
    safety_assured do
      execute <<~SQL.squish
        UPDATE skateparks
        SET skatepark_videos_count = (
          SELECT COUNT(*)
          FROM skatepark_videos
          WHERE skatepark_videos.skatepark_id = skateparks.id
            AND skatepark_videos.status = 1
        )
      SQL
    end
  end
end
