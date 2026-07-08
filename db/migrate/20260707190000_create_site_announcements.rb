# frozen_string_literal: true

class CreateSiteAnnouncements < ActiveRecord::Migration[8.1]
  def change
    create_table :site_announcements do |t|
      t.boolean :published, null: false, default: false
      t.integer :position, null: false
      t.datetime :starts_at
      t.datetime :ends_at
      t.string :link_url

      t.timestamps
    end
  end
end
