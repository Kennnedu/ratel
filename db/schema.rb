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

ActiveRecord::Schema.define(version: 2021_06_02_204351) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cards", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_cards_on_user_id"
  end

  create_table "gmail_connections", force: :cascade do |t|
    t.bigint "user_id"
    t.boolean "connected", default: false
    t.string "report_sender"
    t.datetime "connected_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_gmail_connections_on_user_id"
  end

  create_table "records", force: :cascade do |t|
    t.string "name"
    t.decimal "amount"
    t.float "rest"
    t.datetime "performed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "card_id"
    t.bigint "report_id"
    t.index ["card_id"], name: "index_records_on_card_id"
    t.index ["name"], name: "index_records_on_name"
    t.index ["report_id"], name: "index_records_on_report_id"
  end

  create_table "records_tags", force: :cascade do |t|
    t.bigint "tag_id"
    t.bigint "record_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_id"], name: "index_records_tags_on_record_id"
    t.index ["tag_id"], name: "index_records_tags_on_tag_id"
  end

  create_table "reports", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "status", default: 0
    t.string "error_message"
    t.jsonb "document_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "rules", force: :cascade do |t|
    t.string "type"
    t.string "name"
    t.jsonb "condition"
    t.bigint "user_id"
    t.bigint "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_rules_on_tag_id"
    t.index ["user_id"], name: "index_rules_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_tags_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["username"], name: "index_users_on_username"
  end

  add_foreign_key "records", "reports"
end
