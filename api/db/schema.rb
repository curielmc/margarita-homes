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

ActiveRecord::Schema[8.1].define(version: 2026_02_10_045916) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "admin_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
  end

  create_table "data_sources", force: :cascade do |t|
    t.string "base_url"
    t.datetime "created_at", null: false
    t.datetime "last_scraped_at"
    t.string "name"
    t.string "source_type"
    t.datetime "updated_at", null: false
  end

  create_table "market_snapshots", force: :cascade do |t|
    t.decimal "avg_price", precision: 12, scale: 2
    t.datetime "created_at", null: false
    t.integer "listing_count", default: 0
    t.decimal "max_price", precision: 12, scale: 2
    t.decimal "median_price", precision: 12, scale: 2
    t.decimal "min_price", precision: 12, scale: 2
    t.date "period_end", null: false
    t.date "period_start", null: false
    t.decimal "price_per_sqft", precision: 10, scale: 2
    t.string "property_type"
    t.integer "sold_count", default: 0
    t.datetime "updated_at", null: false
    t.bigint "zone_id", null: false
    t.index ["zone_id", "property_type", "period_start"], name: "idx_snapshots_zone_type_period", unique: true
    t.index ["zone_id"], name: "index_market_snapshots_on_zone_id"
  end

  create_table "price_histories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "data_source_id"
    t.text "notes"
    t.string "price_type", default: "asking", null: false
    t.decimal "price_usd", precision: 12, scale: 2, null: false
    t.bigint "property_id", null: false
    t.datetime "recorded_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data_source_id"], name: "index_price_histories_on_data_source_id"
    t.index ["price_type"], name: "index_price_histories_on_price_type"
    t.index ["property_id"], name: "index_price_histories_on_property_id"
    t.index ["recorded_at"], name: "index_price_histories_on_recorded_at"
  end

  create_table "properties", force: :cascade do |t|
    t.string "address"
    t.decimal "bathrooms", precision: 3, scale: 1
    t.integer "bedrooms"
    t.datetime "created_at", null: false
    t.decimal "current_price_usd", precision: 12, scale: 2
    t.bigint "data_source_id"
    t.text "description"
    t.boolean "featured", default: false
    t.decimal "latitude", precision: 10, scale: 7
    t.date "listed_at"
    t.decimal "longitude", precision: 10, scale: 7
    t.decimal "lot_sqft", precision: 10, scale: 2
    t.string "property_type", default: "house", null: false
    t.date "sold_at"
    t.string "source_url"
    t.decimal "sqft", precision: 10, scale: 2
    t.string "status", default: "active", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "year_built"
    t.bigint "zone_id", null: false
    t.index ["current_price_usd"], name: "index_properties_on_current_price_usd"
    t.index ["data_source_id"], name: "index_properties_on_data_source_id"
    t.index ["featured"], name: "index_properties_on_featured"
    t.index ["property_type"], name: "index_properties_on_property_type"
    t.index ["status"], name: "index_properties_on_status"
    t.index ["zone_id"], name: "index_properties_on_zone_id"
  end

  create_table "property_photos", force: :cascade do |t|
    t.string "caption"
    t.datetime "created_at", null: false
    t.boolean "is_primary", default: false
    t.integer "position", default: 0
    t.bigint "property_id", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["property_id"], name: "index_property_photos_on_property_id"
  end

  create_table "zones", force: :cascade do |t|
    t.jsonb "bounds_json"
    t.datetime "created_at", null: false
    t.text "description"
    t.decimal "latitude", precision: 10, scale: 7
    t.decimal "longitude", precision: 10, scale: 7
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_zones_on_slug", unique: true
  end

  add_foreign_key "market_snapshots", "zones"
  add_foreign_key "price_histories", "data_sources"
  add_foreign_key "price_histories", "properties"
  add_foreign_key "properties", "data_sources"
  add_foreign_key "properties", "zones"
  add_foreign_key "property_photos", "properties"
end
