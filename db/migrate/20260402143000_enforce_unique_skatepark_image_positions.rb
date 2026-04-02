class EnforceUniqueSkateparkImagePositions < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  NON_UNIQUE_INDEX_NAME = 'index_skatepark_images_on_skatepark_id_and_position'.freeze
  UNIQUE_INDEX_NAME = 'index_unique_skatepark_images_on_skatepark_id_and_position'.freeze

  def up
    normalize_skatepark_image_positions!
    add_index :skatepark_images,
              %i[skatepark_id position],
              unique: true,
              algorithm: :concurrently,
              name: UNIQUE_INDEX_NAME
    remove_index :skatepark_images, name: NON_UNIQUE_INDEX_NAME, algorithm: :concurrently
  end

  def down
    add_index :skatepark_images, %i[skatepark_id position], algorithm: :concurrently, name: NON_UNIQUE_INDEX_NAME
    remove_index :skatepark_images, name: UNIQUE_INDEX_NAME, algorithm: :concurrently
  end

  private

  def normalize_skatepark_image_positions!
    safety_assured do
      execute <<~SQL.squish
        WITH ordered_images AS (
          SELECT
            id,
            ROW_NUMBER() OVER (PARTITION BY skatepark_id ORDER BY position, id) AS normalized_position
          FROM skatepark_images
        )
        UPDATE skatepark_images
        SET position = ordered_images.normalized_position
        FROM ordered_images
        WHERE skatepark_images.id = ordered_images.id
          AND skatepark_images.position <> ordered_images.normalized_position
      SQL
    end
  end
end
