class AddCityGeonameIdToSkateparks < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_column :skateparks, :city_geoname_id, :bigint
    add_index :skateparks, :city_geoname_id, algorithm: :concurrently
  end
end
