class CreateSkateparks < ActiveRecord::Migration[7.2]
  def change
    create_table :skateparks do |t|
      t.string :name
      t.decimal :lat, precision: 10, scale: 6
      t.decimal :lng, precision: 10, scale: 6

      t.timestamps
    end
  end
end
