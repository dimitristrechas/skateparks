class RemoveDiscardedAtFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :discarded_at, :datetime
  end
end
