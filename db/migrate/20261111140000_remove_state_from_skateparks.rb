class RemoveStateFromSkateparks < ActiveRecord::Migration[8.1]
  def change
    remove_index :skateparks, :state
    safety_assured { remove_column :skateparks, :state, :string }
  end
end
