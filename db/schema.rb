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

ActiveRecord::Schema.define(version: 2018_07_15_044132) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "bank_accounts", force: :cascade do |t|
    t.text "plaid_access_token"
    t.text "plaid_item_id"
    t.text "plaid_account_id"
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "card_requests", force: :cascade do |t|
    t.bigint "creator_id"
    t.bigint "event_id"
    t.bigint "fulfilled_by_id"
    t.datetime "fulfilled_at"
    t.bigint "daily_limit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "shipping_address"
    t.string "full_name"
    t.datetime "rejected_at"
    t.datetime "accepted_at"
    t.datetime "canceled_at"
    t.text "notes"
    t.bigint "card_id"
    t.index ["card_id"], name: "index_card_requests_on_card_id"
    t.index ["creator_id"], name: "index_card_requests_on_creator_id"
    t.index ["event_id"], name: "index_card_requests_on_event_id"
    t.index ["fulfilled_by_id"], name: "index_card_requests_on_fulfilled_by_id"
  end

  create_table "cards", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "event_id"
    t.bigint "daily_limit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "last_four"
    t.string "full_name"
    t.text "address"
    t.integer "expiration_month"
    t.integer "expiration_year"
    t.text "emburse_id"
    t.index ["event_id"], name: "index_cards_on_event_id"
    t.index ["user_id"], name: "index_cards_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "content"
    t.string "commentable_type"
    t.bigint "commentable_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type"
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "documents", force: :cascade do |t|
    t.bigint "event_id"
    t.text "name"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_documents_on_event_id"
    t.index ["user_id"], name: "index_documents_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.text "name"
    t.datetime "start"
    t.datetime "end"
    t.text "address"
    t.decimal "sponsorship_fee"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fee_relationships", force: :cascade do |t|
    t.bigint "event_id"
    t.boolean "fee_applies"
    t.bigint "fee_amount"
    t.boolean "is_fee_payment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_fee_relationships_on_event_id"
  end

  create_table "g_suite_accounts", force: :cascade do |t|
    t.text "address"
    t.datetime "accepted_at"
    t.datetime "rejected_at"
    t.bigint "g_suite_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "verified_at"
    t.bigint "creator_id"
    t.text "backup_email"
    t.string "initial_password"
    t.index ["creator_id"], name: "index_g_suite_accounts_on_creator_id"
    t.index ["g_suite_id"], name: "index_g_suite_accounts_on_g_suite_id"
  end

  create_table "g_suite_applications", force: :cascade do |t|
    t.bigint "creator_id"
    t.bigint "event_id"
    t.bigint "fulfilled_by_id"
    t.text "domain"
    t.datetime "rejected_at"
    t.datetime "accepted_at"
    t.datetime "canceled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "g_suite_id"
    t.index ["creator_id"], name: "index_g_suite_applications_on_creator_id"
    t.index ["event_id"], name: "index_g_suite_applications_on_event_id"
    t.index ["fulfilled_by_id"], name: "index_g_suite_applications_on_fulfilled_by_id"
    t.index ["g_suite_id"], name: "index_g_suite_applications_on_g_suite_id"
  end

  create_table "g_suites", force: :cascade do |t|
    t.text "domain"
    t.bigint "event_id"
    t.text "verification_key"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_g_suites_on_event_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.bigint "sponsor_id"
    t.text "stripe_invoice_id"
    t.bigint "amount_due"
    t.bigint "amount_paid"
    t.bigint "amount_remaining"
    t.bigint "attempt_count"
    t.boolean "attempted"
    t.text "stripe_charge_id"
    t.text "memo"
    t.datetime "due_date"
    t.bigint "ending_balance"
    t.boolean "forgiven"
    t.boolean "paid"
    t.bigint "starting_balance"
    t.text "statement_descriptor"
    t.bigint "subtotal"
    t.bigint "tax"
    t.decimal "tax_percent"
    t.bigint "total"
    t.text "item_description"
    t.bigint "item_amount"
    t.text "item_stripe_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "closed"
    t.text "hosted_invoice_url"
    t.text "invoice_pdf"
    t.bigint "creator_id"
    t.index ["creator_id"], name: "index_invoices_on_creator_id"
    t.index ["item_stripe_id"], name: "index_invoices_on_item_stripe_id", unique: true
    t.index ["sponsor_id"], name: "index_invoices_on_sponsor_id"
    t.index ["stripe_invoice_id"], name: "index_invoices_on_stripe_invoice_id", unique: true
  end

  create_table "load_card_requests", force: :cascade do |t|
    t.bigint "card_id"
    t.bigint "creator_id"
    t.bigint "fulfilled_by_id"
    t.bigint "load_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "accepted_at"
    t.datetime "rejected_at"
    t.datetime "canceled_at"
    t.string "emburse_transaction_id"
    t.index ["card_id"], name: "index_load_card_requests_on_card_id"
    t.index ["creator_id"], name: "index_load_card_requests_on_creator_id"
    t.index ["fulfilled_by_id"], name: "index_load_card_requests_on_fulfilled_by_id"
  end

  create_table "organizer_position_invites", force: :cascade do |t|
    t.bigint "event_id"
    t.text "email"
    t.bigint "user_id"
    t.bigint "sender_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "accepted_at"
    t.datetime "rejected_at"
    t.bigint "organizer_position_id"
    t.index ["event_id"], name: "index_organizer_position_invites_on_event_id"
    t.index ["organizer_position_id"], name: "index_organizer_position_invites_on_organizer_position_id"
    t.index ["sender_id"], name: "index_organizer_position_invites_on_sender_id"
    t.index ["user_id"], name: "index_organizer_position_invites_on_user_id"
  end

  create_table "organizer_positions", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_organizer_positions_on_event_id"
    t.index ["user_id"], name: "index_organizer_positions_on_user_id"
  end

  create_table "sponsors", force: :cascade do |t|
    t.bigint "event_id"
    t.text "name"
    t.text "contact_email"
    t.text "address_line1"
    t.text "address_line2"
    t.text "address_city"
    t.text "address_state"
    t.text "address_postal_code"
    t.text "stripe_customer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.index ["event_id"], name: "index_sponsors_on_event_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.text "plaid_id"
    t.text "transaction_type"
    t.text "plaid_category_id"
    t.text "name"
    t.bigint "amount"
    t.date "date"
    t.text "location_address"
    t.text "location_city"
    t.text "location_state"
    t.text "location_zip"
    t.decimal "location_lat"
    t.decimal "location_lng"
    t.text "payment_meta_reference_number"
    t.text "payment_meta_ppd_id"
    t.boolean "pending"
    t.text "pending_transaction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "bank_account_id"
    t.text "payment_meta_by_order_of"
    t.text "payment_meta_payee"
    t.text "payment_meta_payer"
    t.text "payment_meta_payment_method"
    t.text "payment_meta_payment_processor"
    t.text "payment_meta_reason"
    t.bigint "fee_relationship_id"
    t.datetime "deleted_at"
    t.boolean "is_event_related"
    t.bigint "load_card_request_id"
    t.index ["bank_account_id"], name: "index_transactions_on_bank_account_id"
    t.index ["deleted_at"], name: "index_transactions_on_deleted_at"
    t.index ["fee_relationship_id"], name: "index_transactions_on_fee_relationship_id"
    t.index ["load_card_request_id"], name: "index_transactions_on_load_card_request_id"
    t.index ["plaid_id"], name: "index_transactions_on_plaid_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.integer "api_id"
    t.text "api_access_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "session_token"
    t.text "email"
    t.string "full_name"
    t.index ["api_access_token"], name: "index_users_on_api_access_token", unique: true
    t.index ["api_id"], name: "index_users_on_api_id", unique: true
  end

  add_foreign_key "card_requests", "cards"
  add_foreign_key "card_requests", "events"
  add_foreign_key "card_requests", "users", column: "creator_id"
  add_foreign_key "card_requests", "users", column: "fulfilled_by_id"
  add_foreign_key "cards", "events"
  add_foreign_key "cards", "users"
  add_foreign_key "documents", "events"
  add_foreign_key "documents", "users"
  add_foreign_key "fee_relationships", "events"
  add_foreign_key "g_suite_accounts", "g_suites"
  add_foreign_key "g_suite_accounts", "users", column: "creator_id"
  add_foreign_key "g_suite_applications", "events"
  add_foreign_key "g_suite_applications", "g_suites"
  add_foreign_key "g_suite_applications", "users", column: "creator_id"
  add_foreign_key "g_suite_applications", "users", column: "fulfilled_by_id"
  add_foreign_key "g_suites", "events"
  add_foreign_key "invoices", "sponsors"
  add_foreign_key "invoices", "users", column: "creator_id"
  add_foreign_key "load_card_requests", "cards"
  add_foreign_key "load_card_requests", "users", column: "creator_id"
  add_foreign_key "load_card_requests", "users", column: "fulfilled_by_id"
  add_foreign_key "organizer_position_invites", "events"
  add_foreign_key "organizer_position_invites", "organizer_positions"
  add_foreign_key "organizer_position_invites", "users"
  add_foreign_key "organizer_position_invites", "users", column: "sender_id"
  add_foreign_key "organizer_positions", "events"
  add_foreign_key "organizer_positions", "users"
  add_foreign_key "sponsors", "events"
  add_foreign_key "transactions", "bank_accounts"
  add_foreign_key "transactions", "fee_relationships"
  add_foreign_key "transactions", "load_card_requests"
end
