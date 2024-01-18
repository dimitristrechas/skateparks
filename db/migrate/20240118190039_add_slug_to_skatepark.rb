class AddSlugToSkatepark < ActiveRecord::Migration[7.2]
  def change
    add_column :skateparks, :slug, :string
  end
end
