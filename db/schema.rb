# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_10_28_123855) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "candidates", force: :cascade do |t|
    t.string "name_cn"
    t.string "name_en"
    t.string "avatar"
    t.string "category"
    t.string "source_channel"
    t.string "input_method"
    t.bigint "created_by"
    t.bigint "owner_id"
    t.string "email"
    t.string "email1"
    t.string "email2"
    t.string "phone"
    t.string "phone1"
    t.string "phone2"
    t.string "industry"
    t.string "title"
    t.decimal "annual_salary", precision: 10, scale: 2
    t.datetime "date_of_birth"
    t.string "gender"
    t.string "city"
    t.string "address"
    t.text "description"
    t.jsonb "tags", default: []
    t.string "linkedin"
    t.string "interview_willingness"
    t.decimal "expert_ratio", precision: 10, scale: 2
    t.string "bank"
    t.string "bank_account"
    t.string "bank_card_number"
    t.jsonb "property", default: {}
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name_cn"
    t.string "name_en"
    t.string "role"
    t.string "title"
    t.string "status"
    t.string "phone"
    t.datetime "date_of_birth"
    t.datetime "date_of_employment"
    t.datetime "date_of_resignation"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
