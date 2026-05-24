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

ActiveRecord::Schema[8.1].define(version: 2026_05_17_174116) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"
  enable_extension "postgis"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
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

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "invitations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "invitee_email", null: false
    t.uuid "inviter_id", null: false
    t.uuid "neighborhood_id", null: false
    t.integer "status", default: 0, null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["invitee_email"], name: "index_invitations_on_invitee_email"
    t.index ["inviter_id"], name: "index_invitations_on_inviter_id"
    t.index ["neighborhood_id"], name: "index_invitations_on_neighborhood_id"
    t.index ["token"], name: "index_invitations_on_token", unique: true
  end

  create_table "items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "available", default: true, null: false
    t.integer "category", default: 0, null: false
    t.integer "condition", default: 0, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "flagged", default: false, null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["available", "flagged"], name: "index_items_on_available_and_flagged"
    t.index ["available"], name: "index_items_on_available"
    t.index ["category"], name: "index_items_on_category"
    t.index ["flagged"], name: "index_items_on_flagged"
    t.index ["user_id"], name: "index_items_on_user_id"
  end

  create_table "loans", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "borrower_id", null: false
    t.datetime "created_at", null: false
    t.date "end_date", null: false
    t.uuid "item_id", null: false
    t.text "message"
    t.date "start_date", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["borrower_id"], name: "index_loans_on_borrower_id"
    t.index ["item_id", "status"], name: "index_loans_on_item_id_and_status"
    t.index ["item_id"], name: "index_loans_on_item_id"
    t.index ["status"], name: "index_loans_on_status"
  end

  create_table "neighborhoods", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.geography "location", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.string "name", null: false
    t.float "radius_km", default: 2.0
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["location"], name: "index_neighborhoods_on_location", using: :gist
    t.index ["slug"], name: "index_neighborhoods_on_slug", unique: true
  end

  create_table "notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "action", null: false
    t.uuid "actor_id", null: false
    t.datetime "created_at", null: false
    t.uuid "notifiable_id", null: false
    t.string "notifiable_type", null: false
    t.datetime "read_at"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["actor_id"], name: "index_notifications_on_actor_id"
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["user_id", "read_at"], name: "index_notifications_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.geography "location", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.string "name", null: false
    t.uuid "neighborhood_id"
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["location"], name: "index_users_on_location", using: :gist
    t.index ["neighborhood_id"], name: "index_users_on_neighborhood_id"
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "invitations", "neighborhoods"
  add_foreign_key "invitations", "users", column: "inviter_id"
  add_foreign_key "items", "users"
  add_foreign_key "loans", "items"
  add_foreign_key "loans", "users", column: "borrower_id"
  add_foreign_key "notifications", "users"
  add_foreign_key "notifications", "users", column: "actor_id"
  add_foreign_key "sessions", "users"
  add_foreign_key "users", "neighborhoods"
end
