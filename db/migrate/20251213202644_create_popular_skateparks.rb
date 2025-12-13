class CreatePopularSkateparks < ActiveRecord::Migration[8.0]
  def change
    create_table :popular_skateparks do |t|
      t.references :skatepark, null: false, foreign_key: true, index: { unique: true }
      t.integer :position, null: false

      t.timestamps
    end
  end
end
