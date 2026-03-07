class AddForeignKeyToAuditLogs < ActiveRecord::Migration[8.0]
  def change
    # Clean orphaned records first (if any exist)
    orphaned_count = AuditLog.where.not(actor_id: User.select(:id)).count
    if orphaned_count > 0
      Rails.logger.warn "Deleting #{orphaned_count} orphaned audit logs"
      AuditLog.where.not(actor_id: User.select(:id)).delete_all
    end

    add_foreign_key :audit_logs, :users,
                    column: :actor_id,
                    on_delete: :restrict
  end
end
