class AddStatusToSkatepark < ActiveRecord::Migration[7.2]
  def change
    add_column :skateparks, :status, :integer
  end
end
