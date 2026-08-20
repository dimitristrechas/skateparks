class AddMissingSiteAnnouncementsIndexes < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :site_announcements, :position,
              unique: true,
              if_not_exists: true,
              algorithm: :concurrently,
              name: 'index_site_announcements_on_position'

    add_index :site_announcements, %i[published starts_at ends_at],
              if_not_exists: true,
              algorithm: :concurrently,
              name: 'index_site_announcements_on_published_and_starts_at_and_ends_at'
  end
end
