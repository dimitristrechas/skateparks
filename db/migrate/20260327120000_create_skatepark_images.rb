class CreateSkateparkImages < ActiveRecord::Migration[8.1]
  def change
    create_table :skatepark_images do |t|
      t.references :skatepark, null: false, foreign_key: true
      t.integer :position, null: false

      t.timestamps
    end

    add_index :skatepark_images, %i[skatepark_id position]
  end
end
