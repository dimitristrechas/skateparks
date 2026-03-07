class AddIndexesForPerformance < ActiveRecord::Migration[8.0]
  def change
    add_index :users, :banned_at
    add_index :sessions, :expires_at
  end
end
