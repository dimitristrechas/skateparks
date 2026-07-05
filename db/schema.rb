# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_05_220000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "locale"
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name", "locale"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_postgresql_files", force: :cascade do |t|
    t.string "key"
    t.oid "oid"
    t.index ["key"], name: "index_active_storage_postgresql_files_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "audit_logs", force: :cascade do |t|
    t.string "action", null: false
    t.integer "actor_id", null: false
    t.datetime "created_at", null: false
    t.jsonb "details", default: {}
    t.integer "target_id", null: false
    t.string "target_type", null: false
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_audit_logs_on_action"
    t.index ["actor_id"], name: "index_audit_logs_on_actor_id"
    t.index ["created_at"], name: "index_audit_logs_on_created_at"
    t.index ["target_type", "target_id"], name: "index_audit_logs_on_target_type_and_target_id"
  end

  create_table "mobility_string_translations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "key", null: false
    t.string "locale", null: false
    t.bigint "translatable_id"
    t.string "translatable_type"
    t.datetime "updated_at", null: false
    t.string "value"
    t.index ["translatable_id", "translatable_type", "key"], name: "index_mobility_string_translations_on_translatable_attribute"
    t.index ["translatable_id", "translatable_type", "locale", "key"], name: "index_mobility_string_translations_on_keys", unique: true
    t.index ["translatable_type", "key", "value", "locale"], name: "index_mobility_string_translations_on_query_keys"
  end

  create_table "mobility_text_translations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "key", null: false
    t.string "locale", null: false
    t.bigint "translatable_id"
    t.string "translatable_type"
    t.datetime "updated_at", null: false
    t.text "value"
    t.index ["translatable_id", "translatable_type", "key"], name: "index_mobility_text_translations_on_translatable_attribute"
    t.index ["translatable_id", "translatable_type", "locale", "key"], name: "index_mobility_text_translations_on_keys", unique: true
  end

  create_table "popular_skateparks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "position", null: false
    t.bigint "skatepark_id", null: false
    t.datetime "updated_at", null: false
    t.index ["skatepark_id"], name: "index_popular_skateparks_on_skatepark_id", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.string "ip_address"
    t.string "session_token", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["expires_at"], name: "index_sessions_on_expires_at"
    t.index ["session_token"], name: "index_sessions_on_session_token", unique: true
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "skatepark_images", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "position", null: false
    t.bigint "skatepark_id", null: false
    t.datetime "updated_at", null: false
    t.index ["skatepark_id", "position"], name: "index_unique_skatepark_images_on_skatepark_id_and_position", unique: true
    t.index ["skatepark_id"], name: "index_skatepark_images_on_skatepark_id"
  end

  create_table "skatepark_videos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "position", null: false
    t.bigint "proposed_skatepark_id"
    t.bigint "skatepark_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.string "youtube_url", null: false
    t.string "youtube_video_id", limit: 11, null: false
    t.index ["proposed_skatepark_id"], name: "index_skatepark_videos_on_proposed_skatepark_id"
    t.index ["skatepark_id", "position"], name: "index_skatepark_videos_on_skatepark_id_and_position_active", unique: true, where: "(status = 1)"
    t.index ["skatepark_id", "youtube_video_id"], name: "index_skatepark_videos_on_skatepark_id_and_youtube_video_id", unique: true, where: "(status = ANY (ARRAY[0, 1]))"
    t.index ["skatepark_id"], name: "index_skatepark_videos_on_skatepark_id"
  end

  create_table "skateparks", force: :cascade do |t|
    t.string "country_code"
    t.datetime "created_at", null: false
    t.string "google_id"
    t.decimal "lat", precision: 10, scale: 6
    t.decimal "lng", precision: 10, scale: 6
    t.string "name"
    t.integer "skatepark_videos_count", default: 0, null: false
    t.string "slug"
    t.string "state"
    t.integer "status", null: false
    t.datetime "updated_at", null: false
    t.index ["country_code"], name: "index_skateparks_on_country_code"
    t.index ["state"], name: "index_skateparks_on_state"
  end

  create_table "users", force: :cascade do |t|
    t.text "ban_reason"
    t.datetime "banned_at"
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["banned_at"], name: "index_users_on_banned_at"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "audit_logs", "users", column: "actor_id", on_delete: :restrict
  add_foreign_key "popular_skateparks", "skateparks"
  add_foreign_key "sessions", "users"
  add_foreign_key "skatepark_images", "skateparks"
  add_foreign_key "skatepark_videos", "skateparks"
  add_foreign_key "skatepark_videos", "skateparks", column: "proposed_skatepark_id"
end
