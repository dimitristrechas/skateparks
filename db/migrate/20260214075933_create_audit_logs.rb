class CreateAuditLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :audit_logs do |t|
      t.integer :actor_id, null: false
      t.string :target_type, null: false
      t.integer :target_id, null: false
      t.string :action, null: false
      t.jsonb :details, default: {}

      t.timestamps
    end

    add_index :audit_logs, :actor_id
    add_index :audit_logs, [:target_type, :target_id]
    add_index :audit_logs, :action
    add_index :audit_logs, :created_at
  end
end
