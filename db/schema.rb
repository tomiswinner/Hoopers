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

ActiveRecord::Schema.define(version: 2022_01_19_045231) do

  create_table "areas", force: :cascade do |t|
    t.integer "prefecture_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["prefecture_id"], name: "index_areas_on_prefecture_id"
  end

  create_table "court_favorites", force: :cascade do |t|
    t.integer "court_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["court_id"], name: "index_court_favorites_on_court_id"
    t.index ["user_id"], name: "index_court_favorites_on_user_id"
  end

  create_table "court_histories", force: :cascade do |t|
    t.integer "court_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["court_id"], name: "index_court_histories_on_court_id"
    t.index ["user_id"], name: "index_court_histories_on_user_id"
  end

  create_table "court_reviews", force: :cascade do |t|
    t.integer "court_id", null: false
    t.integer "user_id", null: false
    t.float "total_points", null: false
    t.float "accessibility", null: false
    t.float "security", null: false
    t.float "quality", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["court_id"], name: "index_court_reviews_on_court_id"
    t.index ["user_id"], name: "index_court_reviews_on_user_id"
  end

  create_table "court_tag_taggings", force: :cascade do |t|
    t.integer "court_id", null: false
    t.integer "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["court_id"], name: "index_court_tag_taggings_on_court_id"
    t.index ["tag_id"], name: "index_court_tag_taggings_on_tag_id"
  end

  create_table "courts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "area_id", null: false
    t.string "name", null: false
    t.string "image_id", null: false
    t.string "address", null: false
    t.decimal "latitude", precision: 9, scale: 6, null: false
    t.decimal "longitude", precision: 9, scale: 6, null: false
    t.integer "open_time"
    t.integer "close_time"
    t.string "url", null: false
    t.string "supplement", null: false
    t.string "size", null: false
    t.string "price", null: false
    t.integer "court_type", null: false
    t.boolean "business_status", null: false
    t.boolean "confirmation_status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_id"], name: "index_courts_on_area_id"
    t.index ["user_id"], name: "index_courts_on_user_id"
  end

  create_table "event_favorites", force: :cascade do |t|
    t.integer "event_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_event_favorites_on_event_id"
    t.index ["user_id"], name: "index_event_favorites_on_user_id"
  end

  create_table "event_histories", force: :cascade do |t|
    t.integer "event_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_event_histories_on_event_id"
    t.index ["user_id"], name: "index_event_histories_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.integer "court_id", null: false
    t.integer "user_id", null: false
    t.string "name", null: false
    t.string "image_id"
    t.string "description", null: false
    t.string "condition", null: false
    t.string "contact", null: false
    t.datetime "open_time", null: false
    t.datetime "close_time", null: false
    t.boolean "status", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["court_id"], name: "index_events_on_court_id"
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "prefectures", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", null: false
    t.boolean "is_active", default: true, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
