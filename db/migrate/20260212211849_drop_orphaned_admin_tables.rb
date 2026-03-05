class DropOrphanedAdminTables < ActiveRecord::Migration[8.0]
  def change
    drop_table :admin_skateparks, if_exists: true
    drop_table :admins, if_exists: true
  end
end
