class MigrateSkateparkImagesToRecords < ActiveRecord::Migration[8.1]
  class MigrationSkatepark < ApplicationRecord
    self.table_name = "skateparks"
  end

  class MigrationSkateparkImage < ApplicationRecord
    self.table_name = "skatepark_images"
  end

  class MigrationActiveStorageAttachment < ApplicationRecord
    self.table_name = "active_storage_attachments"
  end

  def up
    MigrationSkatepark.find_each do |skatepark|
      attachments_for(skatepark).each_with_index do |attachment, index|
        skatepark_image = MigrationSkateparkImage.create!(
          skatepark_id: skatepark.id,
          position: index + 1,
          created_at: attachment.created_at,
          updated_at: attachment.created_at
        )

        attachment.update_columns(
          record_type: "SkateparkImage",
          record_id: skatepark_image.id,
          name: "image"
        )
      end
    end
  end

  def down
    MigrationSkateparkImage.order(:skatepark_id, :position, :id).find_each do |skatepark_image|
      MigrationActiveStorageAttachment.where(
        record_type: "SkateparkImage",
        record_id: skatepark_image.id,
        name: "image"
      ).update_all(
        record_type: "Skatepark",
        record_id: skatepark_image.skatepark_id,
        name: "images"
      )
    end
  end

  private

  def attachments_for(skatepark)
    MigrationActiveStorageAttachment.where(
      record_type: "Skatepark",
      record_id: skatepark.id,
      name: "images"
    ).order(:id)
  end
end
