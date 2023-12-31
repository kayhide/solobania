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

ActiveRecord::Schema[7.0].define(version: 2023_08_27_212552) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "acts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "actable_type"
    t.bigint "actable_id"
    t.string "mark"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actable_type", "actable_id"], name: "index_acts_on_actable"
    t.index ["user_id"], name: "index_acts_on_user_id"
  end

  create_table "packs", force: :cascade do |t|
    t.string "category", null: false
    t.string "name", null: false
    t.integer "grade"
    t.string "grade_unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "spec_id", null: false
    t.index ["spec_id"], name: "index_packs_on_spec_id"
  end

  create_table "problems", force: :cascade do |t|
    t.bigint "sheet_id", null: false
    t.string "type"
    t.integer "count", null: false
    t.json "body"
    t.json "spec"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order", default: 0, null: false
    t.index ["sheet_id"], name: "index_problems_on_sheet_id"
  end

  create_table "sheets", force: :cascade do |t|
    t.bigint "pack_id", null: false
    t.string "name", null: false
    t.integer "timelimit", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pack_id"], name: "index_sheets_on_pack_id"
  end

  create_table "specs", force: :cascade do |t|
    t.string "key", null: false
    t.string "name", null: false
    t.json "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_specs_on_key", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email"
  end

  add_foreign_key "acts", "users"
  add_foreign_key "packs", "specs"
  add_foreign_key "problems", "sheets"
  add_foreign_key "sheets", "packs"
end
