class RemoveGoogleUrlFromSkatepark < ActiveRecord::Migration[7.2]
  def change
    remove_column :skateparks, :google_url
  end
end
