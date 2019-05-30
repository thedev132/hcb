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

ActiveRecord::Schema.define(version: 2019_05_22_215806) do

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
    t.text "slug"
    t.index ["event_id"], name: "index_cards_on_event_id"
    t.index ["slug"], name: "index_cards_on_slug", unique: true
    t.index ["user_id"], name: "index_cards_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "content"
    t.string "commentable_type"
    t.bigint "commentable_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin_only", default: false, null: false
    t.index ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type"
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "document_downloads", force: :cascade do |t|
    t.bigint "document_id"
    t.bigint "user_id"
    t.inet "ip_address"
    t.text "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_id"], name: "index_document_downloads_on_document_id"
    t.index ["user_id"], name: "index_document_downloads_on_user_id"
  end

  create_table "documents", force: :cascade do |t|
    t.bigint "event_id"
    t.text "name"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "slug"
    t.index ["event_id"], name: "index_documents_on_event_id"
    t.index ["slug"], name: "index_documents_on_slug", unique: true
    t.index ["user_id"], name: "index_documents_on_user_id"
  end

  create_table "emburse_transactions", force: :cascade do |t|
    t.string "emburse_id"
    t.integer "amount"
    t.integer "state"
    t.string "emburse_department_id"
    t.bigint "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "notified_admin_at"
    t.string "emburse_card_id"
    t.bigint "card_id"
    t.bigint "merchant_mid"
    t.integer "merchant_mcc"
    t.text "merchant_name"
    t.text "merchant_address"
    t.text "merchant_city"
    t.text "merchant_state"
    t.text "merchant_zip"
    t.text "category_emburse_id"
    t.text "category_url"
    t.text "category_code"
    t.text "category_name"
    t.text "category_parent"
    t.text "label"
    t.text "location"
    t.text "note"
    t.text "receipt_url"
    t.text "receipt_filename"
    t.datetime "transaction_time"
    t.datetime "deleted_at"
    t.index ["card_id"], name: "index_emburse_transactions_on_card_id"
    t.index ["deleted_at"], name: "index_emburse_transactions_on_deleted_at"
    t.index ["event_id"], name: "index_emburse_transactions_on_event_id"
  end

  create_table "events", force: :cascade do |t|
    t.text "name"
    t.datetime "start"
    t.datetime "end"
    t.text "address"
    t.decimal "sponsorship_fee"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "emburse_department_id"
    t.text "slug"
    t.bigint "point_of_contact_id"
    t.integer "expected_budget"
    t.boolean "has_fiscal_sponsorship_document"
    t.index ["point_of_contact_id"], name: "index_events_on_point_of_contact_id"
  end

  create_table "exports", force: :cascade do |t|
    t.text "type"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["type"], name: "index_exports_on_type"
    t.index ["user_id"], name: "index_exports_on_user_id"
  end

  create_table "fee_reimbursements", force: :cascade do |t|
    t.bigint "amount"
    t.string "transaction_memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "processed_at"
    t.string "mailer_queued_job_id"
    t.index ["transaction_memo"], name: "index_fee_reimbursements_on_transaction_memo", unique: true
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

  create_table "friendly_id_slugs", id: :serial, force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
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
    t.string "first_name"
    t.string "last_name"
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
    t.text "dkim_key"
    t.index ["event_id"], name: "index_g_suites_on_event_id"
  end

  create_table "invoice_payouts", force: :cascade do |t|
    t.text "stripe_payout_id"
    t.bigint "amount"
    t.datetime "arrival_date"
    t.boolean "automatic"
    t.text "stripe_balance_transaction_id"
    t.datetime "stripe_created_at"
    t.text "currency"
    t.text "description"
    t.text "stripe_destination_id"
    t.text "failure_stripe_balance_transaction_id"
    t.text "failure_code"
    t.text "failure_message"
    t.text "method"
    t.text "source_type"
    t.text "statement_descriptor"
    t.text "status"
    t.text "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["failure_stripe_balance_transaction_id"], name: "index_invoice_payouts_on_failure_stripe_balance_transaction_id", unique: true
    t.index ["stripe_balance_transaction_id"], name: "index_invoice_payouts_on_stripe_balance_transaction_id", unique: true
    t.index ["stripe_payout_id"], name: "index_invoice_payouts_on_stripe_payout_id", unique: true
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
    t.boolean "auto_advance"
    t.text "hosted_invoice_url"
    t.text "invoice_pdf"
    t.bigint "creator_id"
    t.datetime "manually_marked_as_paid_at"
    t.bigint "manually_marked_as_paid_user_id"
    t.text "manually_marked_as_paid_reason"
    t.bigint "payout_id"
    t.datetime "payout_creation_queued_at"
    t.datetime "payout_creation_queued_for"
    t.text "payout_creation_queued_job_id"
    t.datetime "payout_creation_balance_available_at"
    t.text "slug"
    t.text "number"
    t.datetime "finalized_at"
    t.text "status"
    t.integer "payout_creation_balance_net"
    t.integer "payout_creation_balance_stripe_fee"
    t.boolean "reimbursable", default: true
    t.bigint "fee_reimbursement_id"
    t.boolean "livemode"
    t.text "payment_method_type"
    t.text "payment_method_card_brand"
    t.text "payment_method_card_checks_address_line1_check"
    t.text "payment_method_card_checks_address_postal_code_check"
    t.text "payment_method_card_checks_cvc_check"
    t.text "payment_method_card_country"
    t.text "payment_method_card_exp_month"
    t.text "payment_method_card_exp_year"
    t.text "payment_method_card_funding"
    t.text "payment_method_card_last4"
    t.text "payment_method_ach_credit_transfer_bank_name"
    t.text "payment_method_ach_credit_transfer_routing_number"
    t.text "payment_method_ach_credit_transfer_account_number"
    t.text "payment_method_ach_credit_transfer_swift_code"
    t.index ["creator_id"], name: "index_invoices_on_creator_id"
    t.index ["fee_reimbursement_id"], name: "index_invoices_on_fee_reimbursement_id"
    t.index ["item_stripe_id"], name: "index_invoices_on_item_stripe_id", unique: true
    t.index ["manually_marked_as_paid_user_id"], name: "index_invoices_on_manually_marked_as_paid_user_id"
    t.index ["payout_creation_queued_job_id"], name: "index_invoices_on_payout_creation_queued_job_id", unique: true
    t.index ["payout_id"], name: "index_invoices_on_payout_id"
    t.index ["slug"], name: "index_invoices_on_slug", unique: true
    t.index ["sponsor_id"], name: "index_invoices_on_sponsor_id"
    t.index ["status"], name: "index_invoices_on_status"
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
    t.bigint "event_id"
    t.index ["card_id"], name: "index_load_card_requests_on_card_id"
    t.index ["creator_id"], name: "index_load_card_requests_on_creator_id"
    t.index ["event_id"], name: "index_load_card_requests_on_event_id"
    t.index ["fulfilled_by_id"], name: "index_load_card_requests_on_fulfilled_by_id"
  end

  create_table "organizer_position_deletion_requests", force: :cascade do |t|
    t.bigint "organizer_position_id"
    t.bigint "submitted_by_id"
    t.bigint "closed_by_id"
    t.datetime "closed_at"
    t.text "reason"
    t.boolean "subject_has_outstanding_expenses_expensify", default: false, null: false
    t.boolean "subject_has_outstanding_transactions_emburse", default: false, null: false
    t.boolean "subject_emails_should_be_forwarded", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["closed_by_id"], name: "index_organizer_position_deletion_requests_on_closed_by_id"
    t.index ["organizer_position_id"], name: "index_organizer_deletion_requests_on_organizer_position_id"
    t.index ["submitted_by_id"], name: "index_organizer_position_deletion_requests_on_submitted_by_id"
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
    t.datetime "cancelled_at"
    t.string "slug"
    t.index ["event_id"], name: "index_organizer_position_invites_on_event_id"
    t.index ["organizer_position_id"], name: "index_organizer_position_invites_on_organizer_position_id"
    t.index ["sender_id"], name: "index_organizer_position_invites_on_sender_id"
    t.index ["slug"], name: "index_organizer_position_invites_on_slug", unique: true
    t.index ["user_id"], name: "index_organizer_position_invites_on_user_id"
  end

  create_table "organizer_positions", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
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
    t.text "slug"
    t.index ["event_id"], name: "index_sponsors_on_event_id"
    t.index ["slug"], name: "index_sponsors_on_slug", unique: true
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
    t.bigint "invoice_payout_id"
    t.text "slug"
    t.text "display_name"
    t.bigint "fee_reimbursement_id"
    t.index ["bank_account_id"], name: "index_transactions_on_bank_account_id"
    t.index ["deleted_at"], name: "index_transactions_on_deleted_at"
    t.index ["fee_reimbursement_id"], name: "index_transactions_on_fee_reimbursement_id"
    t.index ["fee_relationship_id"], name: "index_transactions_on_fee_relationship_id"
    t.index ["invoice_payout_id"], name: "index_transactions_on_invoice_payout_id"
    t.index ["load_card_request_id"], name: "index_transactions_on_load_card_request_id"
    t.index ["plaid_id"], name: "index_transactions_on_plaid_id", unique: true
    t.index ["slug"], name: "index_transactions_on_slug", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.integer "api_id"
    t.text "api_access_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "session_token"
    t.text "email"
    t.string "full_name"
    t.text "phone_number"
    t.datetime "admin_at"
    t.string "slug"
    t.index ["api_access_token"], name: "index_users_on_api_access_token", unique: true
    t.index ["api_id"], name: "index_users_on_api_id", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
  end

  add_foreign_key "card_requests", "cards"
  add_foreign_key "card_requests", "events"
  add_foreign_key "card_requests", "users", column: "creator_id"
  add_foreign_key "card_requests", "users", column: "fulfilled_by_id"
  add_foreign_key "cards", "events"
  add_foreign_key "cards", "users"
  add_foreign_key "document_downloads", "documents"
  add_foreign_key "document_downloads", "users"
  add_foreign_key "documents", "events"
  add_foreign_key "documents", "users"
  add_foreign_key "emburse_transactions", "cards"
  add_foreign_key "emburse_transactions", "events"
  add_foreign_key "events", "users", column: "point_of_contact_id"
  add_foreign_key "exports", "users"
  add_foreign_key "fee_relationships", "events"
  add_foreign_key "g_suite_accounts", "g_suites"
  add_foreign_key "g_suite_accounts", "users", column: "creator_id"
  add_foreign_key "g_suite_applications", "events"
  add_foreign_key "g_suite_applications", "g_suites"
  add_foreign_key "g_suite_applications", "users", column: "creator_id"
  add_foreign_key "g_suite_applications", "users", column: "fulfilled_by_id"
  add_foreign_key "g_suites", "events"
  add_foreign_key "invoices", "fee_reimbursements"
  add_foreign_key "invoices", "invoice_payouts", column: "payout_id"
  add_foreign_key "invoices", "sponsors"
  add_foreign_key "invoices", "users", column: "creator_id"
  add_foreign_key "invoices", "users", column: "manually_marked_as_paid_user_id"
  add_foreign_key "load_card_requests", "cards"
  add_foreign_key "load_card_requests", "events"
  add_foreign_key "load_card_requests", "users", column: "creator_id"
  add_foreign_key "load_card_requests", "users", column: "fulfilled_by_id"
  add_foreign_key "organizer_position_deletion_requests", "organizer_positions"
  add_foreign_key "organizer_position_deletion_requests", "users", column: "closed_by_id"
  add_foreign_key "organizer_position_deletion_requests", "users", column: "submitted_by_id"
  add_foreign_key "organizer_position_invites", "events"
  add_foreign_key "organizer_position_invites", "organizer_positions"
  add_foreign_key "organizer_position_invites", "users"
  add_foreign_key "organizer_position_invites", "users", column: "sender_id"
  add_foreign_key "organizer_positions", "events"
  add_foreign_key "organizer_positions", "users"
  add_foreign_key "sponsors", "events"
  add_foreign_key "transactions", "bank_accounts"
  add_foreign_key "transactions", "fee_reimbursements"
  add_foreign_key "transactions", "fee_relationships"
  add_foreign_key "transactions", "invoice_payouts"
  add_foreign_key "transactions", "load_card_requests"
end
