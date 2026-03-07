class AddSessionTokenToSessions < ActiveRecord::Migration[8.0]
  def change
    add_column :sessions, :session_token, :string
    add_index :sessions, :session_token, unique: true

    # Backfill existing sessions with secure random tokens
    reversible do |dir|
      dir.up do
        Session.reset_column_information
        Session.find_each do |session|
          session.update_column(:session_token, SecureRandom.urlsafe_base64(32))
        end
      end
    end

    change_column_null :sessions, :session_token, false
  end
end
