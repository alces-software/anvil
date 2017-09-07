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

ActiveRecord::Schema.define(version: 20170907103244) do

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

  create_table "customizers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", limit: 512, null: false
    t.string "description"
    t.uuid "user_id"
    t.string "s3_url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "summary"
    t.index ["name", "user_id"], name: "index_customizers_on_name_and_user_id", unique: true
  end

  create_table "gridware_packages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "group"
    t.string "version", null: false
    t.string "summary"
    t.string "url"
    t.string "description"
    t.string "package_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.text "changelog"
    t.index ["name", "version", "package_type"], name: "index_gridware_packages_on_name_and_version_and_package_type", unique: true
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
    t.index ["name"], name: "index_users_on_name", unique: true
  end

end
