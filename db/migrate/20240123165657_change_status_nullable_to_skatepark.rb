class ChangeStatusNullableToSkatepark < ActiveRecord::Migration[7.2]
  def change
    change_column_null :skateparks, :status, false, 0
  end
end
