class AddGoogleUrlToSkatepark < ActiveRecord::Migration[7.2]
  def change
    add_column :skateparks, :google_url, :string
  end
end
