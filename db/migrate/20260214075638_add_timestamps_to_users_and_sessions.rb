class AddTimestampsToUsersAndSessions < ActiveRecord::Migration[8.0]
  def change
    add_timestamps :users, default: -> { 'CURRENT_TIMESTAMP' }, null: false
    add_timestamps :sessions, default: -> { 'CURRENT_TIMESTAMP' }, null: false

    change_column_default :users, :created_at, from: -> { 'CURRENT_TIMESTAMP' }, to: nil
    change_column_default :users, :updated_at, from: -> { 'CURRENT_TIMESTAMP' }, to: nil
    change_column_default :sessions, :created_at, from: -> { 'CURRENT_TIMESTAMP' }, to: nil
    change_column_default :sessions, :updated_at, from: -> { 'CURRENT_TIMESTAMP' }, to: nil
  end
end
