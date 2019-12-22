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

ActiveRecord::Schema.define(version: 2019_12_14_083633) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "candidate_experiences", force: :cascade do |t|
    t.bigint "candidate_id"
    t.string "category"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.string "org_cn"
    t.string "org_en"
    t.string "department"
    t.string "title"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["candidate_id"], name: "index_candidate_experiences_on_candidate_id"
  end

  create_table "candidates", force: :cascade do |t|
    t.string "category"
    t.string "data_source"
    t.bigint "created_by"
    t.bigint "company_id"
    t.string "name_cn"
    t.string "name_en"
    t.string "city"
    t.string "email"
    t.string "email1"
    t.string "phone"
    t.string "phone1"
    t.string "industry"
    t.datetime "date_of_birth"
    t.string "gender"
    t.text "description"
    t.boolean "is_available"
    t.decimal "cpt", precision: 10, scale: 2
    t.string "bank"
    t.string "bank_card"
    t.string "bank_user"
    t.string "alipay_account"
    t.string "alipay_user"
    t.jsonb "property", default: {}
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["company_id"], name: "index_candidates_on_company_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "category"
    t.bigint "created_by"
    t.string "name"
    t.string "name_abbr"
    t.string "tax_id"
    t.string "industry"
    t.string "city"
    t.string "address"
    t.string "phone"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "contracts", force: :cascade do |t|
    t.bigint "created_by"
    t.bigint "company_id"
    t.string "file"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.decimal "cpt", precision: 10, scale: 2
    t.integer "min_bill_duration"
    t.integer "follow_bill_duration"
    t.string "payment_time"
    t.string "payment_way"
    t.boolean "is_tax_included"
    t.boolean "is_invoice_needed"
    t.jsonb "financial_info", default: {}
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["company_id"], name: "index_contracts_on_company_id"
  end

  create_table "location_data", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.integer "level"
    t.bigint "parent_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "project_candidates", force: :cascade do |t|
    t.string "category"
    t.bigint "project_id"
    t.bigint "candidate_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["candidate_id"], name: "index_project_candidates_on_candidate_id"
    t.index ["project_id"], name: "index_project_candidates_on_project_id"
  end

  create_table "project_users", force: :cascade do |t|
    t.string "category"
    t.bigint "project_id"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["project_id"], name: "index_project_users_on_project_id"
    t.index ["user_id"], name: "index_project_users_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.bigint "created_by"
    t.bigint "company_id"
    t.string "name"
    t.string "code"
    t.string "status"
    t.text "requirement"
    t.string "industry"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["company_id"], name: "index_projects_on_company_id"
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
    t.string "unconfirmed_email"
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
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
