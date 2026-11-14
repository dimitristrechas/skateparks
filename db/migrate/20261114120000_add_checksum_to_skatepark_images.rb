class AddChecksumToSkateparkImages < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  INDEX_NAME = 'index_unique_skatepark_images_on_skatepark_id_and_checksum'.freeze

  def up
    add_column :skatepark_images, :checksum, :string
    backfill_checksums!
    delete_duplicate_images!
    add_index :skatepark_images,
              %i[skatepark_id checksum],
              unique: true,
              algorithm: :concurrently,
              name: INDEX_NAME
  end

  def down
    remove_index :skatepark_images, name: INDEX_NAME, algorithm: :concurrently
    safety_assured { remove_column :skatepark_images, :checksum }
  end

  private

  def backfill_checksums!
    safety_assured do
      execute <<~SQL.squish
        UPDATE skatepark_images
        SET checksum = active_storage_blobs.checksum
        FROM active_storage_attachments
        INNER JOIN active_storage_blobs ON active_storage_blobs.id = active_storage_attachments.blob_id
        WHERE active_storage_attachments.record_type = 'SkateparkImage'
          AND active_storage_attachments.record_id = skatepark_images.id
          AND active_storage_attachments.name = 'image'
      SQL
    end
  end

  def delete_duplicate_images!
    safety_assured do
      execute <<~SQL.squish
        WITH ranked_images AS (
          SELECT id,
                 ROW_NUMBER() OVER (PARTITION BY skatepark_id, checksum ORDER BY position, id) AS rank
          FROM skatepark_images
          WHERE checksum IS NOT NULL
        ), duplicates AS (
          SELECT id FROM ranked_images WHERE rank > 1
        )
        DELETE FROM active_storage_attachments
        WHERE record_type = 'SkateparkImage'
          AND record_id IN (SELECT id FROM duplicates)
      SQL

      execute <<~SQL.squish
        WITH ranked_images AS (
          SELECT id,
                 ROW_NUMBER() OVER (PARTITION BY skatepark_id, checksum ORDER BY position, id) AS rank
          FROM skatepark_images
          WHERE checksum IS NOT NULL
        )
        DELETE FROM skatepark_images
        WHERE id IN (SELECT id FROM ranked_images WHERE rank > 1)
      SQL
    end
  end
end
