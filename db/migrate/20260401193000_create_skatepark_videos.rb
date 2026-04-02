class CreateSkateparkVideos < ActiveRecord::Migration[8.1]
  def change
    create_table :skatepark_videos do |t|
      t.references :skatepark, null: false, foreign_key: true
      t.string :youtube_url, null: false
      t.integer :position, null: false

      t.timestamps
    end

    add_index :skatepark_videos, %i[skatepark_id position], unique: true

    add_column :skateparks, :skatepark_videos_count, :integer, default: 0, null: false
  end
end
