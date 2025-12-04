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

ActiveRecord::Schema[8.1].define(version: 2025_12_04_081136) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.bigint "author_id"
    t.string "author_type"
    t.text "body"
    t.datetime "created_at", null: false
    t.string "namespace"
    t.bigint "resource_id"
    t.string "resource_type"
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "appointments", force: :cascade do |t|
    t.datetime "appointment_date"
    t.datetime "created_at", null: false
    t.text "reason"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_appointments_on_user_id"
  end

  create_table "audiograms", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "image_file"
    t.text "notes"
    t.jsonb "thresholds", default: {}
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_audiograms_on_user_id"
  end

  create_table "carts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hearing_aids", force: :cascade do |t|
    t.string "battery_type"
    t.boolean "bluetooth"
    t.string "brand"
    t.datetime "created_at", null: false
    t.string "device_model"
    t.text "features"
    t.string "image_url"
    t.integer "max_gain"
    t.decimal "price", precision: 10, scale: 2
    t.integer "stock"
    t.text "technical_specs"
    t.datetime "updated_at", null: false
    t.string "warranty"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "cart_id", null: false
    t.datetime "created_at", null: false
    t.bigint "hearing_aid_id", null: false
    t.integer "quantity"
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_order_items_on_cart_id"
    t.index ["hearing_aid_id"], name: "index_order_items_on_hearing_aid_id"
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "status"
    t.string "stripe_payment_id"
    t.decimal "total_amount"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "recommendations", force: :cascade do |t|
    t.bigint "audiogram_id", null: false
    t.text "audiologist_notes"
    t.datetime "created_at", null: false
    t.bigint "hearing_aid_id", null: false
    t.text "notes"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.datetime "validated_at"
    t.index ["audiogram_id"], name: "index_recommendations_on_audiogram_id"
    t.index ["hearing_aid_id"], name: "index_recommendations_on_hearing_aid_id"
    t.index ["user_id"], name: "index_recommendations_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "appointments", "users"
  add_foreign_key "audiograms", "users"
  add_foreign_key "order_items", "carts"
  add_foreign_key "order_items", "hearing_aids"
  add_foreign_key "orders", "users"
  add_foreign_key "recommendations", "audiograms"
  add_foreign_key "recommendations", "hearing_aids"
  add_foreign_key "recommendations", "users"
end
