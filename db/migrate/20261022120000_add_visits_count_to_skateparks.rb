class AddVisitsCountToSkateparks < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_column :skateparks, :visits_count, :integer, default: 0, null: false
    add_index :skateparks, %i[visits_count id], algorithm: :concurrently, if_not_exists: true
  end
end
