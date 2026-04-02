class AddUniqueIndexToSkateparkVideosYoutubeUrl < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :skatepark_videos, %i[skatepark_id youtube_url], unique: true, algorithm: :concurrently
  end
end
