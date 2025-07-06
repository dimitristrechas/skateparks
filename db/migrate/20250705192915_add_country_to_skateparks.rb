class AddCountryToSkateparks < ActiveRecord::Migration[8.0]
  def change
    add_column :skateparks, :country_code, :string
    add_index :skateparks, :country_code
  end
end
