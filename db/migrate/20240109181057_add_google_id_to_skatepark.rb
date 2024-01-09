class AddGoogleIdToSkatepark < ActiveRecord::Migration[7.2]
  def change
    add_column :skateparks, :google_id, :string
  end
end
