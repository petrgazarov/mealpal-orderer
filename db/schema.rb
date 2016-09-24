# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160924215241) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "events", force: :cascade do |t|
    t.string   "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
  end

  create_table "order_days", force: :cascade do |t|
    t.integer  "week_day_number",                                null: false
    t.text     "whitelist",          default: [],                             array: true
    t.text     "blacklist",          default: [],                             array: true
    t.string   "pick_up_time",       default: "12:00pm-12:15pm"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "user_id"
    t.boolean  "scheduled_to_order", default: true
  end

  add_index "order_days", ["user_id", "week_day_number"], name: "index_order_days_on_user_id_and_week_day_number", unique: true, using: :btree

  create_table "ordered_items", force: :cascade do |t|
    t.string   "name"
    t.string   "restaurant_name"
    t.datetime "ordered_at"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "mealpal_email",                 null: false
    t.string   "mealpal_password",              null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.text     "order_days",       default: [],              array: true
    t.string   "address"
  end

  add_foreign_key "order_days", "users"
  add_foreign_key "ordered_items", "users"
end
