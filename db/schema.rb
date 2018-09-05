# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180905130005) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pgcrypto"

  create_table "articles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
  end

  create_table "categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.uuid "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "collection_memberships", force: :cascade do |t|
    t.uuid "collection_id", null: false
    t.uuid "package_id"
    t.index ["collection_id", "package_id"], name: "index_collection_memberships_on_collection_id_and_package_id", unique: true
  end

  create_table "collections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "name", limit: 512, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "packages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.string "name", limit: 512, null: false
    t.string "description"
    t.string "summary"
    t.text "changelog"
    t.string "licence", limit: 512
    t.string "website"
    t.string "package_url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "version"
    t.uuid "category_id", null: false
    t.string "dependencies", default: [], array: true
    t.index ["name", "version", "user_id"], name: "index_packages_on_name_and_version_and_user_id", unique: true
  end

  create_table "taggings", force: :cascade do |t|
    t.string "tag_id", null: false
    t.uuid "taggable_id", null: false
    t.string "taggable_type", null: false
    t.index ["taggable_id", "taggable_type"], name: "index_taggings_on_taggable_id_and_taggable_type"
  end

  create_table "tags", id: :string, force: :cascade do |t|
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.uuid "flight_id", default: "09cff8a7-48c6-4cbd-b33b-e5babfb47af5", null: false
    t.index ["name"], name: "index_users_on_name", unique: true
  end

  add_foreign_key "articles", "users"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "collection_memberships", "collections"
  add_foreign_key "collection_memberships", "packages"
  add_foreign_key "collections", "users"
  add_foreign_key "packages", "categories"
  add_foreign_key "taggings", "tags"
end
