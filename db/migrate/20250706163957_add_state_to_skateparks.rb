class AddStateToSkateparks < ActiveRecord::Migration[8.0]
  def change
    add_column :skateparks, :state, :string
    add_index :skateparks, :state
  end
end
