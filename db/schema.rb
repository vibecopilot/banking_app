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

ActiveRecord::Schema.define(version: 2026_05_26_074300) do

  create_table "abouts", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.text "description"
    t.integer "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "account_groups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.string "group_type", null: false
    t.integer "parent_id"
    t.integer "site_id"
    t.text "description"
    t.boolean "active", default: true
    t.boolean "is_system", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code", "site_id"], name: "index_account_groups_on_code_and_site_id", unique: true
    t.index ["group_type"], name: "index_account_groups_on_group_type"
    t.index ["parent_id"], name: "index_account_groups_on_parent_id"
    t.index ["site_id"], name: "index_account_groups_on_site_id"
  end

  create_table "accounting_invoice_items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "accounting_invoice_id", null: false
    t.string "description"
    t.integer "ledger_id"
    t.decimal "quantity", precision: 10, scale: 2, default: "1.0"
    t.decimal "unit_price", precision: 15, scale: 2, default: "0.0"
    t.decimal "amount", precision: 15, scale: 2, null: false
    t.integer "tax_rate_id"
    t.decimal "tax_amount", precision: 15, scale: 2, default: "0.0"
    t.decimal "total_amount", precision: 15, scale: 2, null: false
    t.string "item_type"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "s_no"
    t.string "service_description"
    t.text "service_details"
    t.string "hsn_sac_code"
    t.decimal "rate", precision: 15, scale: 2
    t.decimal "taxable_value", precision: 15, scale: 2
    t.decimal "cgst_rate", precision: 5, scale: 2
    t.decimal "cgst_amount", precision: 15, scale: 2
    t.decimal "sgst_rate", precision: 5, scale: 2
    t.decimal "sgst_amount", precision: 15, scale: 2
    t.decimal "igst_rate", precision: 5, scale: 2
    t.decimal "igst_amount", precision: 15, scale: 2
    t.decimal "total", precision: 15, scale: 2
    t.string "gst_type", default: "cgst_sgst"
    t.index ["accounting_invoice_id"], name: "index_accounting_invoice_items_on_accounting_invoice_id"
    t.index ["ledger_id"], name: "index_accounting_invoice_items_on_ledger_id"
    t.index ["tax_rate_id"], name: "index_accounting_invoice_items_on_tax_rate_id"
  end

  create_table "accounting_invoices", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "invoice_number", null: false
    t.date "invoice_date", null: false
    t.date "due_date"
    t.integer "site_id", null: false
    t.integer "unit_id"
    t.integer "user_id"
    t.integer "vendor_id"
    t.string "invoice_type"
    t.decimal "subtotal", precision: 15, scale: 2, default: "0.0"
    t.decimal "tax_amount", precision: 15, scale: 2, default: "0.0"
    t.decimal "total_amount", precision: 15, scale: 2, default: "0.0"
    t.decimal "paid_amount", precision: 15, scale: 2, default: "0.0"
    t.decimal "balance_amount", precision: 15, scale: 2, default: "0.0"
    t.string "status", default: "draft"
    t.text "notes"
    t.text "terms_and_conditions"
    t.integer "journal_entry_id"
    t.integer "created_by_id"
    t.datetime "sent_at"
    t.datetime "paid_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "customer_name"
    t.string "customer_email"
    t.text "customer_address"
    t.string "bank_account"
    t.string "bank_ifsc"
    t.string "bank_aic"
    t.string "gst_reverse_charge"
    t.string "place_of_supply"
    t.string "state"
    t.string "state_code"
    t.string "unit_no"
    t.string "gst_no"
    t.integer "amount"
    t.string "payment_mode"
    t.string "payment_ref_no"
    t.string "source_type"
    t.decimal "gst_input_value", precision: 15, scale: 2, default: "0.0"
    t.integer "income_month"
    t.integer "income_year"
    t.index ["due_date"], name: "index_accounting_invoices_on_due_date"
    t.index ["invoice_date"], name: "index_accounting_invoices_on_invoice_date"
    t.index ["invoice_number"], name: "index_accounting_invoices_on_invoice_number", unique: true
    t.index ["journal_entry_id"], name: "index_accounting_invoices_on_journal_entry_id"
    t.index ["site_id"], name: "index_accounting_invoices_on_site_id"
    t.index ["status"], name: "index_accounting_invoices_on_status"
    t.index ["unit_id"], name: "index_accounting_invoices_on_unit_id"
    t.index ["user_id"], name: "index_accounting_invoices_on_user_id"
    t.index ["vendor_id"], name: "index_accounting_invoices_on_vendor_id"
  end

  create_table "accounting_payments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "payment_number", null: false
    t.date "payment_date", null: false
    t.integer "site_id", null: false
    t.integer "unit_id"
    t.integer "accounting_invoice_id"
    t.integer "user_id"
    t.integer "vendor_id"
    t.string "payment_type"
    t.string "payment_mode"
    t.decimal "amount", precision: 15, scale: 2, null: false
    t.string "reference_number"
    t.text "notes"
    t.integer "journal_entry_id"
    t.integer "received_by_id"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["accounting_invoice_id"], name: "index_accounting_payments_on_accounting_invoice_id"
    t.index ["journal_entry_id"], name: "index_accounting_payments_on_journal_entry_id"
    t.index ["payment_date"], name: "index_accounting_payments_on_payment_date"
    t.index ["payment_number"], name: "index_accounting_payments_on_payment_number", unique: true
    t.index ["payment_type"], name: "index_accounting_payments_on_payment_type"
    t.index ["site_id"], name: "index_accounting_payments_on_site_id"
    t.index ["unit_id"], name: "index_accounting_payments_on_unit_id"
    t.index ["user_id"], name: "index_accounting_payments_on_user_id"
    t.index ["vendor_id"], name: "index_accounting_payments_on_vendor_id"
  end

  create_table "active_storage_attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", limit: 191, null: false
    t.string "record_type", limit: 191, null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", limit: 191, null: false
    t.string "filename", limit: 191, null: false
    t.string "content_type", limit: 191
    t.text "metadata"
    t.string "service_name", limit: 191, null: false
    t.bigint "byte_size", null: false
    t.string "checksum", limit: 191
    t.datetime "created_at", precision: 6, null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", limit: 191, null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "asset_id"
    t.integer "checklist_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string "status"
    t.integer "assigned_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "soft_service_id"
    t.integer "patrolling_id"
    t.integer "group_id"
    t.index ["asset_id", "checklist_id", "start_time"], name: "index_activities_on_asset_id_and_checklist_id_and_start_time"
    t.index ["checklist_id"], name: "composite_index_for_activities"
    t.index ["start_time", "checklist_id"], name: "composite_index_for_activities_start_check"
    t.index ["start_time", "checklist_id"], name: "composite_index_for_checklists"
  end

  create_table "additional_passengers", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.string "gender"
    t.integer "flight_request_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "class_type"
  end

  create_table "address_setups", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "title"
    t.text "address"
    t.integer "building_id"
    t.string "state"
    t.string "phone_number"
    t.string "fax_number"
    t.string "email_address"
    t.string "registration_no"
    t.string "pan_number"
    t.string "cheque_in_favour_of"
    t.string "gst_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "account_number"
    t.string "account_type"
    t.string "ifsc_code"
    t.string "account_name"
    t.string "bank_branch_name"
    t.integer "site_id"
  end

  create_table "addresses", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "address_title"
    t.string "building_name"
    t.string "street_name"
    t.string "email_address"
    t.string "state"
    t.string "city"
    t.bigint "phone_number"
    t.integer "pin_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "address"
  end

  create_table "advance_maintenances", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "unit_id", null: false
    t.integer "demand_no", null: false
    t.date "due_date", null: false
    t.decimal "base_amount", precision: 14, scale: 2, null: false
    t.decimal "gst_rate_percent", precision: 5, scale: 2, null: false
    t.decimal "gst_amount", precision: 14, scale: 2, null: false
    t.decimal "total_amount", precision: 14, scale: 2, null: false
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["unit_id", "demand_no"], name: "index_advance_maintenances_on_unit_id_and_demand_no", unique: true
  end

  create_table "advance_payment_ledgers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "unit_id", null: false
    t.integer "months_paid", default: 0, null: false
    t.decimal "amount", precision: 14, scale: 2, default: "0.0", null: false
    t.date "paid_on", null: false
    t.date "possession_date_ref"
    t.string "mode"
    t.string "reference_no"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["unit_id"], name: "index_advance_payment_ledgers_on_unit_id"
  end

  create_table "amc_contacts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "asset_amc_id"
    t.string "name"
    t.string "phone"
    t.string "email"
    t.string "designation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "amc_invoices", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "asset_amc_id"
    t.string "invoice_number"
    t.decimal "amount", precision: 10, scale: 2
    t.date "invoice_date"
    t.string "document"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "amenities", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "site_id"
    t.string "fac_type"
    t.string "fac_name"
    t.integer "member_charges"
    t.integer "book_before"
    t.text "disclaimer"
    t.text "cancellation_policy"
    t.integer "cutoff_min"
    t.integer "return_percentage"
    t.integer "create_by"
    t.boolean "active", default: true
    t.integer "member_price_adult"
    t.integer "member_price_child"
    t.integer "guest_price_adult"
    t.integer "guest_price_child"
    t.integer "min_people"
    t.integer "max_people"
    t.integer "cancel_before"
    t.text "terms"
    t.integer "advance_booking"
    t.integer "deposit"
    t.text "description"
    t.integer "max_slots"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "member"
    t.boolean "guest"
    t.string "gst_no"
    t.string "status", default: "pending"
    t.text "payment_methods", limit: 4294967295, collation: "utf8mb4_bin"
    t.integer "tenant_price_adult"
    t.integer "tenant_price_child"
    t.boolean "tenant"
    t.float "sgst"
    t.boolean "pay_on_facility"
    t.boolean "non_member"
    t.float "non_member_price_adult"
    t.float "non_member_price_child"
    t.boolean "complimentary"
    t.boolean "postpaid"
    t.boolean "prepaid"
    t.float "gst"
    t.boolean "consecutive_slot_allowed"
    t.string "fixed_amount"
    t.boolean "is_fixed"
    t.boolean "is_hotel"
    t.string "no_of_days"
    t.string "type_of_facility"
    t.boolean "is_member_adult"
    t.boolean "is_member_child"
    t.boolean "is_guest_adult"
    t.boolean "is_guest_child"
    t.boolean "is_tenant_child"
    t.boolean "is_tenant_adult"
    t.string "slot_start_time"
    t.string "slot_end_time"
    t.integer "concurrent_slot", default: 1
    t.string "slot_by"
    t.integer "wrap_time", default: 0
    t.string "break_time_start"
    t.string "break_time_end"
  end

  create_table "amenity_booking_rules", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "enumerator"
    t.integer "duration"
    t.string "level"
    t.boolean "active"
    t.integer "amenity_id"
    t.integer "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "facility_can_be_booked"
    t.integer "times_per_day"
    t.string "period_type"
  end

  create_table "amenity_bookings", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "amenity_id"
    t.integer "amenity_slot_id"
    t.integer "user_id"
    t.date "booking_date"
    t.integer "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "amount"
    t.integer "member_adult"
    t.integer "member_child"
    t.integer "guest_adult"
    t.integer "guest_child"
    t.integer "no_of_members"
    t.integer "no_of_guests"
    t.string "status"
    t.string "payment_mode"
    t.integer "no_of_tenants"
    t.integer "tenant_adult"
    t.integer "tenant_child"
    t.datetime "checkin_at"
    t.datetime "checkout_at"
    t.boolean "is_book_hotel"
    t.boolean "is_prime_booking"
  end

  create_table "amenity_notifications", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "amenity_booking_id"
    t.string "message"
    t.string "read"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "amenity_id"
  end

  create_table "amenity_operational_days", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "amenity_id"
    t.integer "day_of_week"
    t.string "start_time"
    t.string "end_time"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["amenity_id"], name: "index_amenity_operational_days_on_amenity_id"
  end

  create_table "amenity_slots", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "amenity_id"
    t.integer "start_hr"
    t.integer "end_hr"
    t.integer "start_min"
    t.integer "end_min"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "aminities", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.integer "site_id"
    t.decimal "cost", precision: 8, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "book_by"
    t.float "tenant_price_adult"
    t.float "tenant_price_children"
    t.string "status"
  end

  create_table "aminity_bookings", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.date "date"
    t.integer "aminity_id"
    t.text "comment"
    t.text "cancellation_policy"
    t.text "terms_and_conditions"
    t.string "payment_method"
    t.integer "user_id"
    t.string "status"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "aminity_setups", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "aminity_id"
    t.string "name"
    t.integer "site_id"
    t.integer "unit_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer "slot_frequency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.time "break_time_start"
    t.time "break_time_end"
    t.text "terms_and_conditions"
    t.string "facility_type"
    t.string "facility_name"
    t.boolean "active"
    t.float "fee"
    t.integer "booking_allowed_before"
    t.integer "advance_booking"
    t.integer "cancel_before"
    t.text "description"
    t.integer "max_bookings_per_week"
    t.time "slot_start_time"
    t.time "slot_end_time"
    t.integer "concurrent_slot", default: 1
    t.string "slot_by"
    t.integer "wrap_time", default: 0
  end

  create_table "aminity_slots", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "aminity_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "approval_levels", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.integer "site_id"
    t.integer "user_id"
    t.integer "order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "approval_id"
    t.decimal "threshold", precision: 10
    t.string "decision", default: "pending"
    t.text "comment"
    t.datetime "acted_at"
    t.index ["approval_id"], name: "index_approval_levels_on_approval_id"
  end

  create_table "approval_logs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "status"
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.string "descriptions"
    t.string "additional_comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "approvals", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "site_id"
    t.integer "user_id"
    t.integer "level_id"
    t.date "start_date"
    t.date "end_date"
    t.integer "resource_id"
    t.string "resource_type"
    t.text "comments"
    t.integer "approved_by_id"
    t.string "approver_comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.integer "current_level", default: 0
    t.decimal "total_amount", precision: 12, scale: 2, default: "0.0"
  end

  create_table "asset_amcs", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "vendor_id"
    t.integer "asset_id"
    t.date "start_date"
    t.date "end_date"
    t.string "frequency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "first_service"
    t.integer "visits"
    t.decimal "amc_cost", precision: 10, scale: 2
    t.text "remarks"
  end

  create_table "asset_group_params", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.integer "order"
    t.integer "asset_group_id"
    t.boolean "dashboard_view"
    t.boolean "consumption_view"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "asset_groups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.string "group_for", default: "asset"
  end

  create_table "asset_measures", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "asset_id"
    t.string "name"
    t.float "min_value"
    t.float "max_value"
    t.float "alert_below"
    t.float "alert_above"
    t.integer "active"
    t.string "unit_type"
    t.integer "multiplier_factor"
    t.string "meter_tag"
    t.integer "meter_unit_id"
    t.boolean "cloned"
    t.boolean "check_previous_reading"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "asset_meter_types", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.string "value"
    t.boolean "active"
    t.string "unit_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "asset_params", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "asset_id"
    t.string "name"
    t.string "param_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "dashboard_view", default: false
    t.boolean "consumption_view", default: false
    t.integer "order"
    t.string "digit"
    t.float "alert_below"
    t.float "alert_above"
    t.float "min_val"
    t.float "max_val"
    t.boolean "check_prev"
    t.string "unit_type"
    t.integer "multiplier_factor"
  end

  create_table "attachfiles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "relation"
    t.integer "relation_id"
    t.string "image_file_name"
    t.string "image_content_type"
    t.bigint "image_file_size"
    t.datetime "image_updated_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category_type"
    t.index ["relation", "relation_id"], name: "composite_index_for_attachfiles"
  end

  create_table "attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.bigint "incident_id"
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["incident_id"], name: "index_attachments_on_incident_id"
  end

  create_table "attendances", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "attendance_of_id"
    t.string "attendance_of_type"
    t.integer "resource_id"
    t.string "resource_type"
    t.datetime "punched_in_at"
    t.datetime "punched_out_at"
    t.text "work_log"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "audit_tasks", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "group"
    t.integer "sub_group"
    t.string "task"
    t.string "input_type"
    t.boolean "mandatory"
    t.boolean "reading"
    t.boolean "help_text"
    t.string "weightage"
    t.boolean "rating"
    t.integer "audit_id"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "audits", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "audit_for"
    t.string "activity_name"
    t.text "description"
    t.boolean "allow_observations"
    t.string "checklist_type"
    t.integer "asset_name"
    t.integer "service_name"
    t.integer "vendor_name"
    t.string "training_name"
    t.integer "assign_to"
    t.string "scan_type"
    t.integer "plan_duration"
    t.string "priority"
    t.string "email_trigger_rule"
    t.integer "supervisors"
    t.integer "category"
    t.string "look_overdue_task"
    t.string "frequency"
    t.datetime "start_from"
    t.datetime "end_at"
    t.integer "select_supplier"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "site_id"
  end

  create_table "banners", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "billing_configurations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "site_id"
    t.string "company_name"
    t.string "company_logo"
    t.string "gst_number"
    t.string "pan_number"
    t.text "address"
    t.string "city"
    t.string "state"
    t.string "pincode"
    t.string "phone"
    t.string "email"
    t.string "website"
    t.string "bank_name"
    t.string "account_number"
    t.string "ifsc_code"
    t.string "branch_name"
    t.text "terms_and_conditions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "enable_gst_split", default: false, null: false
    t.boolean "enable_igst", default: false, null: false
    t.decimal "society_maintenance_percent", precision: 5, scale: 2, default: "0.0", null: false
    t.string "management_fees_label", default: "Management Fees"
    t.string "favouring_name"
    t.string "account_type"
    t.string "swift_code"
    t.boolean "management_fees_enabled", default: false, null: false
    t.index ["site_id"], name: "index_billing_configurations_on_site_id"
  end

  create_table "blocked_days", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "restaurant_id"
    t.date "start_date"
    t.text "reason"
    t.boolean "booking_allowed"
    t.boolean "order_allowed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "end_date"
  end

  create_table "booking_parkings", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "parking_id"
    t.date "booking_date"
    t.datetime "booking_start_time"
    t.datetime "booking_end_time"
    t.integer "user_id"
    t.integer "site_id"
    t.boolean "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "slot_id"
    t.integer "creatde_by_id"
    t.integer "created_by_id"
  end

  create_table "buildings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.integer "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "floor_no"
  end

  create_table "business_cards", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "full_name"
    t.string "profession"
    t.string "contact_number"
    t.string "email_id"
    t.string "website_url"
    t.text "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "site_id"
    t.integer "company_id"
    t.integer "created_by"
  end

  create_table "cab_and_bus_requests", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "employee_name"
    t.integer "employee_id"
    t.string "pickup_location"
    t.string "drop_off_location"
    t.datetime "date_and_time"
    t.integer "number_of_passengers"
    t.string "transportation_type"
    t.text "special_requirements"
    t.text "driver_contact_information"
    t.text "vehicle_details"
    t.integer "booking_confirmation_number"
    t.string "booking_status"
    t.boolean "manager_approval"
    t.string "booking_confirmation_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "mobile_no"
  end

  create_table "cam_bill_charges", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "charge_id"
    t.float "charge_amount"
    t.float "sub_amount"
    t.float "cgst_amount"
    t.float "igst_amount"
    t.float "sgst_amount"
    t.string "description"
    t.integer "cam_bill_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "discount_percent"
    t.float "quantity"
    t.float "unit"
    t.float "rate"
    t.integer "hsn_id"
    t.float "taxable_value"
    t.decimal "cgst_rate", precision: 10
    t.decimal "sgst_rate", precision: 10
    t.decimal "igst_rate", precision: 10
    t.decimal "total_value", precision: 10
    t.decimal "total", precision: 10
    t.decimal "discount_amount", precision: 10
  end

  create_table "cam_bills", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "unit_id"
    t.integer "user_id"
    t.date "bill_date"
    t.date "due_date"
    t.float "total_amount"
    t.integer "created_by"
    t.integer "sub_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invoice_type"
    t.integer "invoice_address_id"
    t.string "invoice_number"
    t.integer "building_id"
    t.integer "flat_id"
    t.float "due_amount"
    t.float "due_amount_interst"
    t.text "note"
    t.date "bill_period_start_date"
    t.date "bill_period_end_date"
    t.date "supply_date"
    t.integer "floor_id"
    t.text "recall_reason"
    t.string "status"
    t.integer "site_id"
    t.string "payment_status"
  end

  create_table "cam_settings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "project_id"
    t.decimal "rate_per_sqft", precision: 12, scale: 4, default: "0.0", null: false
    t.decimal "gst_rate_percent", precision: 5, scale: 2, default: "0.0", null: false
    t.integer "advance_months_required", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cam_unit_bills", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "unit_id", null: false
    t.integer "year", null: false
    t.integer "month", null: false
    t.decimal "carpet_area_sqft", precision: 12, scale: 3, null: false
    t.decimal "daily_rate_per_sqft", precision: 12, scale: 6, null: false
    t.integer "active_days", null: false
    t.decimal "base_amount", precision: 14, scale: 2, null: false
    t.decimal "gst_rate_percent", precision: 5, scale: 2, null: false
    t.decimal "gst_amount", precision: 14, scale: 2, null: false
    t.decimal "total_amount", precision: 14, scale: 2, null: false
    t.string "status", default: "generated", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "site_id"
    t.index ["site_id"], name: "index_cam_unit_bills_on_site_id"
    t.index ["unit_id", "year", "month"], name: "idx_cam_unit_bills_unique_period", unique: true
  end

  create_table "capas", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "complaint_id"
    t.string "title"
    t.text "root_cause"
    t.text "corrective_action"
    t.text "preventive_action"
    t.text "effectiveness"
    t.integer "owner_id"
    t.date "due_date"
    t.string "status", default: "open"
    t.integer "site_id"
    t.integer "created_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["complaint_id"], name: "index_capas_on_complaint_id"
    t.index ["site_id"], name: "index_capas_on_site_id"
    t.index ["status"], name: "index_capas_on_status"
  end

  create_table "cards", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "company_code"
    t.string "tag_type"
    t.string "status"
    t.json "card_data"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "card_id"
    t.index ["user_id"], name: "index_cards_on_user_id"
  end

  create_table "categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "building_id"
    t.index ["building_id"], name: "index_categories_on_building_id"
  end

  create_table "charges", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "site_id"
    t.string "name"
    t.string "code"
    t.float "cgst"
    t.float "sgst"
    t.float "igst"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "hsn_id"
    t.float "discount_percentage"
    t.float "discount_amount"
    t.string "taxable_value"
  end

  create_table "checklist_crons", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "checklist_id"
    t.string "expression"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "checklist_users", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "resource_id"
    t.integer "checklist_id"
    t.string "resource_type"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["checklist_id", "user_id"], name: "composite_index_for_checklist_users"
  end

  create_table "checklists", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "site_id"
    t.string "frequency"
    t.date "start_date"
    t.date "end_date"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "occurs"
    t.string "ctype", default: "routine"
    t.integer "patrolling_id"
    t.string "priority_level"
    t.string "grace_period_unit"
    t.integer "grace_period_value"
    t.integer "grace_period"
    t.integer "supplier_id"
    t.text "supervisior_id"
    t.boolean "weightage_enabled"
    t.boolean "lock_overdue"
    t.integer "company_id"
    t.integer "category_id"
    t.boolean "ticket_enabled"
    t.integer "ticket_assigned_to_id"
    t.string "ticket_level_type"
    t.boolean "active", default: true
    t.boolean "is_approved"
    t.integer "group_id"
    t.integer "sub_group_id"
    t.index ["site_id", "active"], name: "composite_index_for_checklists"
  end

  create_table "color_codes", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "task_id"
    t.integer "user_id"
    t.text "ctext"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "resource_id"
    t.string "resource_type"
    t.integer "rating"
    t.string "comment"
  end

  create_table "communication_groups", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "picture_file_name"
    t.string "picture_content_type"
    t.integer "picture_file_size"
    t.datetime "picture_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "communication_groups_users", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.bigint "communication_group_id"
    t.bigint "user_id"
    t.index ["communication_group_id"], name: "index_communication_groups_users_on_communication_group_id"
    t.index ["user_id"], name: "index_communication_groups_users_on_user_id"
  end

  create_table "companies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "logo_file_name"
    t.string "logo_content_type"
    t.bigint "logo_file_size"
    t.datetime "logo_updated_at"
    t.integer "created_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "organization_id"
    t.string "entity"
    t.string "site"
    t.string "country"
    t.string "region"
    t.string "state"
    t.string "city"
    t.string "zone"
    t.string "white_label"
    t.string "sub_domain"
    t.string "billing_type"
    t.string "billing_for"
    t.string "billing_term"
    t.float "rate_per_bill"
    t.string "billing_cycle"
    t.date "start_time"
    t.date "end_time"
  end

  create_table "complaint_comments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.integer "complaint_id"
    t.text "comment"
    t.integer "changed_by"
    t.integer "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "complaint_log_id"
    t.index ["complaint_id"], name: "index_complaint_comments_on_complaint_id"
    t.index ["complaint_log_id"], name: "index_complaint_comments_on_complaint_log_id"
  end

  create_table "complaint_emails", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "body_json"
    t.string "from"
    t.string "to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "complaint_logs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.integer "complaint_id"
    t.integer "complaint_status_id"
    t.integer "changed_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "assigned_to"
    t.string "priority"
    t.integer "sub_category_id"
    t.text "update_params"
    t.string "society_staff_type", default: "SocietyStaff"
    t.string "mode"
    t.string "issue_related_to"
    t.integer "helpdesk_category_id"
    t.text "comment"
    t.index ["complaint_id", "complaint_status_id"], name: "index_complaint_logs_on_complaint_id_and_complaint_status_id"
    t.index ["complaint_id"], name: "index_complaint_logs_on_complaint_id"
  end

  create_table "complaint_modes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "society_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "active"
    t.string "of_phase", default: "post_possession"
    t.string "of_atype", default: "Society"
    t.index ["society_id"], name: "index_complaint_modes_on_society_id"
  end

  create_table "complaint_statuses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.integer "society_id"
    t.string "name"
    t.string "color_code"
    t.string "fixed_state"
    t.integer "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.string "of_phase", default: "post_possession"
    t.string "of_atype", default: "Society"
    t.index ["society_id", "of_phase"], name: "index_complaint_statuses_on_society_id_and_of_phase"
  end

  create_table "complaint_vendors", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "complaint_id"
    t.integer "pms_supplier_contact_id"
    t.boolean "mail_sent", default: false
    t.datetime "mail_sent_at"
    t.integer "mail_sent_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "complaint_workers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.integer "society_id"
    t.integer "issue_type_id"
    t.integer "category_id"
    t.text "assign_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "assign"
    t.string "esc_type"
    t.string "of_phase", default: "post_possession"
    t.string "of_atype", default: "Society"
    t.integer "cloned_by_id"
    t.datetime "cloned_at"
    t.integer "site_id"
    t.string "issue_related_to"
    t.integer "sub_category_id"
    t.index ["society_id", "esc_type"], name: "index_complaint_workers_on_society_id_and_esc_type"
    t.index ["sub_category_id"], name: "index_complaint_workers_on_sub_category_id"
  end

  create_table "complaints", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "id_society"
    t.integer "id_user"
    t.text "heading"
    t.text "text"
    t.integer "active"
    t.boolean "action"
    t.boolean "IsDelete"
    t.integer "flat_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "category_type_id"
    t.text "issue_type_id"
    t.string "issue_status"
    t.boolean "is_urgent"
    t.integer "updated_by"
    t.integer "user_society_id"
    t.integer "assigned_to"
    t.string "complaint_type"
    t.string "priority"
    t.integer "urgency"
    t.string "ticket_number"
    t.string "on_behalf_of"
    t.string "preventive_action"
    t.integer "person_id"
    t.integer "complaint_mode_id"
    t.date "review_tracking_date"
    t.integer "tower_id"
    t.integer "wing_id"
    t.integer "area_id"
    t.integer "supplier_id"
    t.string "root_cause"
    t.string "proactive_reactive"
    t.string "impact"
    t.string "correction"
    t.string "corrective_action"
    t.integer "society_location_id"
    t.string "issue_related_to"
    t.integer "sub_category_id"
    t.string "of_phase", default: "post_possession"
    t.string "of_atype", default: "Society"
    t.integer "client_society_id"
    t.string "severity"
    t.string "service_type"
    t.string "external_priority"
    t.integer "site_id"
    t.integer "dept_id"
    t.integer "unit_id"
    t.string "society_staff_type", default: "SocietyStaff"
    t.string "project_email"
    t.text "additional_notes"
    t.integer "asset_id"
    t.integer "service_id"
    t.boolean "cost_involved", default: false
    t.string "reference_number"
    t.datetime "closure_date"
    t.integer "society_flat_id"
    t.integer "pms_asset_task_occurrence_id"
    t.datetime "response_time"
    t.datetime "resolution_time"
    t.datetime "response_tat_time"
    t.datetime "resolution_tat_time"
    t.integer "survey_mapping_response_id"
    t.boolean "response_breached", default: false
    t.boolean "resolution_breached", default: false
    t.integer "territory_manager_id"
    t.text "item_ids"
    t.integer "rating"
    t.integer "created_by"
    t.string "ticket_type"
    t.text "impact_details"
    t.string "mode"
    t.datetime "scheduled_start_time"
    t.datetime "scheduled_end_time"
    t.text "solution"
    t.text "workaround"
    t.text "post_incident_action"
    t.string "group_name"
    t.text "items"
    t.text "emails_to_notify"
    t.datetime "due_date_by"
    t.datetime "response_due_date"
    t.string "requester_phone"
    t.string "requester_department"
    t.string "requester_job"
    t.datetime "responded_at"
    t.index ["assigned_to"], name: "index_complaints_on_assigned_to"
    t.index ["category_type_id"], name: "index_complaints_on_category_type_id"
    t.index ["complaint_mode_id"], name: "index_complaints_on_complaint_mode_id"
    t.index ["created_at"], name: "index_complaints_on_created_at"
    t.index ["id_society", "id_user", "of_phase"], name: "index_complaints_on_id_society_and_id_user_and_of_phase"
    t.index ["id_user"], name: "index_complaints_on_id_user"
    t.index ["issue_type_id"], name: "index_complaints_on_issue_type_id", length: 3072
    t.index ["of_phase"], name: "index_complaints_on_of_phase"
    t.index ["site_id"], name: "index_complaints_on_site_id"
    t.index ["society_location_id"], name: "index_complaints_on_society_location_id"
    t.index ["sub_category_id"], name: "index_complaints_on_sub_category_id"
    t.index ["user_society_id"], name: "index_complaints_on_user_society_id"
  end

  create_table "completion_certificates", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "quotation_id", null: false
    t.string "certificate_number", null: false
    t.datetime "issued_at"
    t.text "notes"
    t.text "recipients"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["certificate_number"], name: "index_completion_certificates_on_certificate_number", unique: true
    t.index ["quotation_id"], name: "index_completion_certificates_on_quotation_id"
  end

  create_table "compliance_config_tags", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "compliance_tag_id"
    t.integer "compliance_config_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "compliance_configs", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.string "frequency"
    t.integer "due_in_days"
    t.string "priority"
    t.text "description"
    t.integer "assign_to_id"
    t.integer "reviewer_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cert_number"
  end

  create_table "compliance_tag_tasks", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.integer "weightage"
    t.integer "compliance_tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "mandatory"
  end

  create_table "compliance_tags", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.string "risk"
    t.string "nature"
    t.integer "parent_id"
    t.integer "resource_id"
    t.string "resource_type"
    t.integer "company_id"
    t.string "tag_type"
    t.boolean "critical"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "compliance_tracker_tags", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "compliance_tracker_id"
    t.datetime "submitted_on"
    t.integer "submitted_by_id"
    t.integer "compliance_tag_id"
    t.text "observation"
    t.text "recommendtion"
    t.text "comment"
    t.integer "compliance_tag_task_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "reviewed_by_id"
    t.text "objective"
    t.datetime "reviewed_on"
    t.string "status"
  end

  create_table "compliance_trackers", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "compliance_config_id"
    t.string "status"
    t.datetime "submitted_on"
    t.integer "submitted_by_id"
    t.integer "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "due_date"
  end

  create_table "contact_books", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "company_name"
    t.integer "site_id"
    t.integer "generic_info_id"
    t.bigint "mobile"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "contact_person_name"
    t.string "landline_no"
    t.string "primary_email"
    t.string "secondary_email"
    t.string "website"
    t.text "address"
    t.string "key_offering"
    t.text "description"
    t.string "profile"
    t.boolean "status", default: false
    t.integer "generic_sub_info_id"
  end

  create_table "cost_approval_histories", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "cost_approval_level_id"
    t.integer "cost_approval_request_id"
    t.string "status"
    t.integer "updated_by_id"
    t.datetime "status_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "comments"
  end

  create_table "cost_approval_levels", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.text "escalate_to_users"
    t.integer "cost_approval_id"
    t.boolean "active"
    t.string "access_level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cost_approval_requests", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "cost"
    t.integer "complaint_id"
    t.boolean "active", default: true
    t.text "comment"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
  end

  create_table "cost_approvals", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "cost_from"
    t.integer "cost_to"
    t.string "cost_unit"
    t.string "related_to"
    t.integer "category_type_id"
    t.integer "resource_id"
    t.string "resource_type"
    t.boolean "active", default: true
    t.string "level"
    t.integer "created_by_id"
    t.integer "no_approval_required_from"
    t.integer "no_approval_required_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resource_id"], name: "index_cost_approvals_on_resource_id"
    t.index ["resource_type"], name: "index_cost_approvals_on_resource_type"
  end

  create_table "cost_centres", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "lock_account_id"
    t.string "name"
    t.boolean "active", default: true
    t.integer "created_by"
    t.float "yearly_budget"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "start_date"
    t.date "end_date"
  end

  create_table "cost_of_incidents", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.decimal "equipment_property_cost", precision: 10
    t.decimal "production_loss", precision: 10
    t.decimal "treatment_cost", precision: 10
    t.decimal "absenteeism_cost", precision: 10
    t.decimal "other_cost", precision: 10
    t.decimal "total_cost", precision: 10
    t.bigint "incident_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["incident_id"], name: "index_cost_of_incidents_on_incident_id"
  end

  create_table "cron_settings", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "cronnable_type", null: false
    t.bigint "cronnable_id", null: false
    t.string "recurrence_type"
    t.integer "year_interval"
    t.string "month"
    t.string "date"
    t.string "day_of_week"
    t.string "hour"
    t.string "minute"
    t.string "cron_expression"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cronnable_type", "cronnable_id"], name: "index_cron_settings_on_cronnable_type_and_cronnable_id"
  end

  create_table "deleted_users", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "email"
    t.string "mobile"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "departments", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "department_name"
    t.integer "site_id"
    t.integer "company_id"
    t.boolean "active"
    t.integer "created_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "esc_histories", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.integer "esc_id"
    t.text "esc_to"
    t.integer "complaint_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "eof", default: "EscalationMatrix"
    t.string "status", default: "open"
    t.datetime "resolved_at"
    t.index ["complaint_id"], name: "index_esc_histories_on_complaint_id"
    t.index ["eof"], name: "index_esc_histories_on_eof"
  end

  create_table "esc_levels", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "esc_id"
    t.string "level"
    t.text "esc_to"
    t.string "time_in"
    t.integer "time_val"
    t.integer "total_minutes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "escalation_matrices", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.integer "society_id"
    t.string "name"
    t.integer "after_days"
    t.text "escalate_to_users"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "complaint_status_id"
    t.integer "active"
    t.integer "p1"
    t.integer "p2"
    t.integer "p3"
    t.integer "p4"
    t.integer "p5"
    t.integer "cw_id"
    t.string "esc_type"
    t.index ["cw_id"], name: "index_escalation_matrices_on_cw_id"
    t.index ["society_id", "cw_id", "esc_type"], name: "index_escalation_matrices_on_society_id_and_cw_id_and_esc_type"
  end

  create_table "event_guests", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "event_id"
    t.string "name"
    t.string "rsvp"
    t.string "company_name"
    t.string "email"
    t.string "mobile"
    t.string "business"
    t.string "rules"
    t.string "charges"
    t.string "industry"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "event_guest_id"
    t.integer "user_id"
    t.string "otp"
    t.string "mobile_number"
    t.string "invitation_token"
    t.integer "visitor_id"
    t.integer "status", default: 0
    t.integer "vhost_id"
    t.index ["invitation_token"], name: "index_event_guests_on_invitation_token", unique: true
    t.index ["vhost_id"], name: "index_event_guests_on_vhost_id"
    t.index ["visitor_id"], name: "index_event_guests_on_visitor_id"
  end

  create_table "event_users", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "event_id"
    t.integer "user_id"
    t.string "rsvp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "check_in_token"
    t.boolean "checked_in"
    t.datetime "checked_in_at"
    t.integer "event_guest_id"
    t.boolean "read", default: false
    t.datetime "read_at"
    t.boolean "archived", default: false
    t.datetime "archived_at"
  end

  create_table "events", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "site_id"
    t.string "event_name"
    t.string "venue"
    t.text "discription"
    t.datetime "start_date_time"
    t.datetime "end_date_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "shared"
    t.integer "group_id"
    t.boolean "email_enabled"
    t.boolean "rsvp_enabled"
    t.boolean "important"
    t.integer "created_by"
    t.string "status", default: "upcoming"
    t.boolean "enabled", default: true
  end

  create_table "extensions", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "permit_id"
    t.date "ext_date"
    t.time "ext_time"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "extra_visitors", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.string "contact_no"
    t.integer "visitor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["visitor_id"], name: "index_extra_visitors_on_visitor_id"
  end

  create_table "features", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "site_id"
    t.string "feature_name"
    t.integer "created_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "feedbacks", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "resource_type"
    t.integer "resource_id"
    t.text "comment"
    t.integer "rating"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "field_sense_leads_managements", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "lead_name"
    t.string "lead_source"
    t.string "contact_phone"
    t.string "contact_email"
    t.string "company_name"
    t.string "lead_status"
    t.string "assigned_sales_representative"
    t.date "last_contact_date"
    t.date "next_follow_up_date"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "field_sense_meeting_managements", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "meeting_title"
    t.datetime "meeting_date_and_time"
    t.integer "participants"
    t.string "location"
    t.string "travel_mode"
    t.string "expenses"
    t.text "meeting_agenda"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fit_out_setup_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.integer "position"
    t.integer "society_id"
    t.integer "tat"
    t.boolean "active"
    t.integer "issue_type_id"
    t.string "of_phase"
    t.string "of_atype"
    t.string "icon_file_name"
    t.string "icon_content_type"
    t.integer "icon_file_size"
    t.datetime "icon_updated_at"
    t.text "response_tat"
    t.integer "project_tat"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "assigned_id"
  end

  create_table "fitness_appointments", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "booking_type"
    t.string "name"
    t.string "relationship"
    t.integer "age"
    t.string "gender"
    t.string "marital_status"
    t.date "date"
    t.string "modile_number"
    t.string "preference"
    t.integer "trainer"
    t.text "reason_for_appointment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
  end

  create_table "fitout_documents", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "fitout_request_id"
    t.boolean "active", default: true
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fitout_request_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "fitout_request_id"
    t.integer "category_type_id"
    t.integer "attachfile_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "pending"
    t.integer "updated_by_id"
  end

  create_table "fitout_requests", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "building_id"
    t.integer "floor_id"
    t.integer "unit_id"
    t.integer "user_id"
    t.text "description"
    t.datetime "selected_date"
    t.integer "supplier_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.integer "status_updated_by"
  end

  create_table "fitout_statuses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "society_id"
    t.string "name"
    t.string "color_code"
    t.string "fixed_state"
    t.integer "is_active"
    t.integer "position"
    t.string "of_phase"
    t.string "of_atype"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fitout_subcategories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "fitout_category_name"
    t.integer "fitout_category_id"
    t.string "name"
    t.integer "position"
    t.boolean "active"
    t.integer "issue_type_id"
    t.text "fitout_text"
    t.json "bhk_prices"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "flight_requests", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "employee_name"
    t.integer "employee_id"
    t.string "departure_city"
    t.string "arrival_city"
    t.date "departure_date"
    t.date "return_date"
    t.string "preferred_airlines"
    t.string "flight_class"
    t.string "passenger_name"
    t.string "passport_information"
    t.integer "ticket_confirmation_number"
    t.string "booking_status"
    t.boolean "manager_approval"
    t.string "booking_confirmation_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "mobile_no"
    t.string "email"
  end

  create_table "floors", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.integer "building_id"
    t.integer "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "folder_documents", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "content"
    t.integer "folder_id"
    t.integer "site_id"
    t.integer "uploaded_by"
    t.string "folder_type"
    t.string "of_phase"
    t.integer "unit_id"
    t.string "heavy_video_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_file_name"
    t.string "image_content_type"
    t.bigint "image_file_size"
    t.datetime "image_updated_at"
    t.string "document_type"
    t.integer "created_by"
    t.boolean "active", default: true
  end

  create_table "folders", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.integer "parent_id"
    t.string "structure"
    t.date "date_of_upload"
    t.text "description"
    t.integer "site_id"
    t.integer "uploaded_by"
    t.string "folder_type"
    t.integer "unit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by"
  end

  create_table "food_and_beverages", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "restaurant_name"
    t.float "cost_for_two"
    t.string "mobile_number"
    t.string "alternate_mobile_number"
    t.string "landline_number"
    t.integer "delivery_time"
    t.string "cuisines"
    t.string "serves_alcohols"
    t.string "wheelchair_accessible"
    t.string "cash_on_delivery"
    t.string "pure_veg"
    t.text "address"
    t.text "terms_and_conditions"
    t.text "disclaimer"
    t.text "closing_message"
    t.integer "minimum_person"
    t.integer "maximum_person"
    t.integer "cancel_before"
    t.float "gst"
    t.float "delivery_charges"
    t.integer "minimum_order"
    t.boolean "status"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "restaurant_schedule", limit: 4294967295, collation: "utf8mb4_bin"
    t.float "serviceCharges"
    t.integer "table_number"
    t.date "table_booking_start_date"
    t.date "table_booking_end_date"
    t.time "table_booking_start_time"
    t.time "table_booking_end_time"
    t.integer "booking_capacity"
    t.integer "waiting_capacity"
    t.string "booking_not_available_text"
    t.text "food_and_beverages_availability"
    t.integer "mon"
    t.integer "tue"
    t.integer "wed"
    t.integer "thu"
    t.integer "fri"
    t.integer "sat"
    t.integer "sun"
    t.time "break_start_time"
    t.time "break_end_time"
    t.time "last_booking_time"
    t.boolean "booking_allowed"
    t.boolean "order_allowed"
    t.integer "cuisins_id"
    t.text "order_not_allowed_text"
    t.string "restauranttype"
    t.time "start_time"
    t.time "end_time"
    t.integer "site_id"
    t.string "email"
    t.string "gst_number"
    t.string "license_number"
    t.string "fssai_number"
    t.string "location_branch"
    t.string "delivery_zone"
    t.float "service_radius"
    t.string "tax_type"
    t.string "area_type", default: "single"
    t.text "payment_methods"
    t.string "gpay_upi"
    t.string "phonepe_upi"
    t.string "paytm_upi"
    t.float "cgst_rate", default: 0.0
    t.float "sgst_rate", default: 0.0
    t.float "igst_rate", default: 0.0
    t.float "service_charge_percent", default: 0.0
    t.float "discount_percent", default: 0.0
    t.boolean "razorpay_enabled", default: false
    t.string "razorpay_key"
    t.string "razorpay_secret"
    t.float "convenience_fee"
  end

  create_table "forum_comments", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.bigint "forum_id"
    t.text "comment"
    t.string "image_file_name"
    t.string "image_content_type"
    t.bigint "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["forum_id"], name: "index_forum_comments_on_forum_id"
  end

  create_table "forum_reports", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.bigint "forum_id", null: false
    t.bigint "reported_by_id", null: false
    t.text "reason", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["forum_id"], name: "index_forum_reports_on_forum_id"
    t.index ["reported_by_id"], name: "index_forum_reports_on_reported_by_id"
  end

  create_table "forums", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "thread_title"
    t.string "thread_category"
    t.string "thread_tags"
    t.string "thread_creators"
    t.datetime "date"
    t.text "thread_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.boolean "visible", default: true, null: false
  end

  create_table "gates", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.integer "site_id"
    t.integer "user_id"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gdn_details", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.date "gdn_date"
    t.text "description"
    t.boolean "status"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "purpose_id"
    t.integer "handover_to_id"
    t.text "comments"
    t.decimal "quantity", precision: 10
  end

  create_table "gdn_inventory_details", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "inventory"
    t.integer "current_stock"
    t.integer "quantity"
    t.text "comments"
    t.integer "gdn_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "purpose_id"
    t.integer "handover_to_id"
    t.integer "consuming_in_id"
    t.integer "service_id"
    t.integer "asset_id"
  end

  create_table "generic_infos", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.integer "company_id"
    t.integer "site_id"
    t.string "info_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "time"
  end

  create_table "generic_sub_infos", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "generic_info_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "goods_in_outs", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "visitor_id"
    t.integer "no_of_goods"
    t.string "description"
    t.string "ward_type"
    t.string "vehicle_no"
    t.string "person_name"
    t.datetime "goods_in_time"
    t.datetime "goods_out_time"
    t.integer "staff_id"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "site_id"
    t.string "name"
    t.string "item_type"
    t.string "item_category"
    t.string "mode_of_transport"
    t.string "company_name"
    t.string "department"
    t.datetime "reporting_time"
    t.string "returnable_type"
    t.datetime "expected_date"
  end

  create_table "goods_items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "goods_in_out_id"
    t.string "item_name"
    t.integer "quantity"
    t.string "unit"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["goods_in_out_id"], name: "index_goods_items_on_goods_in_out_id"
  end

  create_table "grn_details", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "loi_detail_id"
    t.integer "vendor_id"
    t.string "payment_mode"
    t.string "invoice_number"
    t.string "related_to"
    t.float "invoice_amount"
    t.datetime "invoice_date"
    t.datetime "posting_date"
    t.float "other_expenses"
    t.float "loading_expenses"
    t.float "adjustment_amount"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "grn_unique_id"
    t.integer "created_by_id"
    t.index ["grn_unique_id"], name: "index_grn_details_on_grn_unique_id", unique: true
  end

  create_table "group_members", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "group_id"
    t.integer "site_id"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "groups", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "group_name"
    t.string "group_type"
    t.integer "group_admin"
    t.string "group_roles"
    t.string "group_permissions"
    t.string "group_activities"
    t.integer "add_members"
    t.text "group_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "site_id"
  end

  create_table "hazard_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "sub_activity_id"
    t.integer "activity_id"
    t.integer "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
  end

  create_table "helpdesk_categories", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "society_id"
    t.string "name"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tat"
    t.integer "active"
    t.integer "issue_type_id"
    t.string "of_phase", default: "post_possession"
    t.string "of_atype", default: "Society"
    t.string "icon_file_name"
    t.string "icon_content_type"
    t.integer "icon_file_size"
    t.datetime "icon_updated_at"
    t.text "response_tat"
    t.integer "project_tat"
    t.integer "assigned_to"
    t.index ["society_id", "of_phase"], name: "index_helpdesk_categories_on_society_id_and_of_phase"
  end

  create_table "helpdesk_operations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "op_of", default: "Society"
    t.integer "op_of_id"
    t.string "dayofweek"
    t.integer "start_hour"
    t.integer "start_min"
    t.integer "end_hour"
    t.integer "end_min"
    t.boolean "is_open", default: false
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "of_phase", default: "post_possession"
    t.index ["op_of", "op_of_id", "of_phase"], name: "index_helpdesk_operations_on_op_of_and_op_of_id_and_of_phase"
  end

  create_table "helpdesk_project_emails", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "email"
    t.integer "created_by"
    t.integer "society_id"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "helpdesk_sub_categories", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "helpdesk_category_id"
    t.string "name"
    t.integer "position"
    t.integer "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "issue_type_id"
    t.text "helpdesk_text"
    t.index ["helpdesk_category_id"], name: "index_helpdesk_sub_categories_on_helpdesk_category_id"
    t.index ["issue_type_id"], name: "index_helpdesk_sub_categories_on_issue_type_id"
  end

  create_table "hik_devices", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.string "ip_address"
    t.string "username"
    t.string "password"
    t.integer "site_id"
    t.integer "building_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hosts", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "visitor_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_approved"
    t.string "approval_mode"
  end

  create_table "hotels", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "hotel_name"
    t.string "location"
    t.integer "site_id"
    t.datetime "check_in_date"
    t.datetime "check_out_date"
    t.boolean "is_available"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "employee_id"
    t.string "employee_name"
    t.string "destination"
    t.integer "number_of_rooms"
    t.string "room_type"
    t.string "special_requests"
    t.string "hotel_preferences"
    t.string "booking_confirmation_number"
    t.string "booking_status"
    t.boolean "manager_approval"
    t.string "booking_certification_email"
    t.string "mobile_no"
    t.string "email"
  end

  create_table "hsns", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "category"
    t.string "code"
    t.float "sgst_rate"
    t.float "cgst_rate"
    t.float "igst_rate"
    t.boolean "active"
    t.integer "created_by"
    t.integer "updated_by"
    t.integer "company_id"
    t.string "hsn_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "incidence_tags", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.boolean "active"
    t.integer "parent_id"
    t.string "tag_type"
    t.integer "resource_id"
    t.string "resource_type"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "incident_injuries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "injury_type"
    t.integer "injury_number"
    t.integer "incident_id"
    t.integer "lost_time"
    t.integer "who_got_injured_id"
    t.string "name"
    t.string "company_name"
    t.string "mobile"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "who_got_injured"
  end

  create_table "incidents", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.datetime "time_and_date"
    t.string "primary_incident_category"
    t.string "secondary_incident_category"
    t.string "incident_severity"
    t.string "incident_level"
    t.integer "building_id"
    t.string "probability"
    t.text "description"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "primary_incident_sub_category"
    t.string "primary_incident_sub_sub_category"
    t.string "secondary_incident_sub_category"
    t.string "secondary_incident_sub_sub_category"
    t.boolean "property_damage", default: false
    t.string "rca"
    t.string "primary_root_cause_category"
    t.text "corrective_action"
    t.text "preventive_action"
    t.boolean "first_aid_provided_employee", default: false
    t.boolean "sent_medical_treatment", default: false
    t.boolean "support_required", default: false
    t.text "read_facts_states"
    t.string "status"
    t.string "insured_by"
    t.string "first_aid_attendant"
    t.string "treatment_facility"
    t.string "attending_physician"
    t.string "property_damage_category"
    t.boolean "damage_coverd_under_insurance"
    t.boolean "read_fact_state"
  end

  create_table "income_entries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "site_id"
    t.string "source_type"
    t.integer "source_id"
    t.decimal "amount", precision: 10
    t.string "invoice_number"
    t.date "received_date"
    t.string "payment_mode"
    t.string "reference_number"
    t.bigint "user_id"
    t.bigint "unit_id"
    t.bigint "journal_entry_id"
    t.string "status"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "income_month"
    t.integer "income_year"
    t.index ["journal_entry_id"], name: "index_income_entries_on_journal_entry_id"
    t.index ["site_id"], name: "index_income_entries_on_site_id"
    t.index ["unit_id"], name: "index_income_entries_on_unit_id"
    t.index ["user_id"], name: "index_income_entries_on_user_id"
  end

  create_table "ingredients", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "sku"
    t.string "category"
    t.string "unit"
    t.decimal "stock_quantity", precision: 12, scale: 3, default: "0.0"
    t.decimal "minimum_stock", precision: 12, scale: 3, default: "0.0"
    t.decimal "unit_price", precision: 10, scale: 2, default: "0.0"
    t.integer "supplier_id"
    t.integer "site_id"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_ingredients_on_category"
    t.index ["site_id"], name: "index_ingredients_on_site_id"
    t.index ["supplier_id"], name: "index_ingredients_on_supplier_id"
  end

  create_table "interest_calculations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "site_id"
    t.bigint "unit_id"
    t.bigint "cam_bill_id"
    t.decimal "principal_amount", precision: 10
    t.decimal "interest_rate", precision: 10
    t.decimal "interest_amount", precision: 10
    t.date "calculation_date"
    t.date "from_date"
    t.date "to_date"
    t.integer "days_overdue"
    t.string "status"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cam_bill_id"], name: "index_interest_calculations_on_cam_bill_id"
    t.index ["site_id"], name: "index_interest_calculations_on_site_id"
    t.index ["unit_id"], name: "index_interest_calculations_on_unit_id"
  end

  create_table "inventories", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.integer "inventory_type"
    t.integer "criticality"
    t.integer "asset_group_id"
    t.integer "asset_sub_group_id"
    t.integer "asset_id"
    t.string "code"
    t.string "serial_number"
    t.float "quantity"
    t.string "min_stock_level"
    t.string "min_order_level"
    t.float "cgst_rate"
    t.float "sgst_rate"
    t.float "igst_rate"
    t.boolean "active"
    t.integer "hsn_id"
    t.datetime "expiry_date"
    t.string "unit"
    t.float "cost"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "site_id"
    t.string "category"
  end

  create_table "inventory_details", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "item_id"
    t.integer "expected_quantity"
    t.integer "received_quantity"
    t.integer "approved_quantity"
    t.integer "rejected_quantity"
    t.float "rate"
    t.float "csgt_rate"
    t.float "csgt_amt"
    t.float "sgst_rate"
    t.float "sgst_amt"
    t.float "igst_rate"
    t.float "igst_amt"
    t.float "tcs_rate"
    t.float "tcs_amt"
    t.float "tax_amt"
    t.float "inventory_amount"
    t.float "total_amount"
    t.integer "grn_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "inventory_type"
    t.integer "criticality"
    t.text "batches"
  end

  create_table "investigation_teams", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.string "mobile"
    t.string "designation"
    t.bigint "incident_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["incident_id"], name: "index_investigation_teams_on_incident_id"
  end

  create_table "invoice_receipts", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "receipt_number"
    t.string "invoice_number"
    t.integer "building_id"
    t.integer "unit_id"
    t.integer "address_id"
    t.string "payment_mode"
    t.decimal "amount_received", precision: 10
    t.string "transaction_or_cheque_number"
    t.string "bank_name"
    t.string "branch_name"
    t.date "payment_date"
    t.date "receipt_date"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cam_bill_id"
    t.string "resource_type"
    t.integer "resource_id"
    t.integer "vendor_id"
    t.integer "site_id"
  end

  create_table "invoice_setups", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "prefix"
    t.integer "next_number"
    t.boolean "auto_generate"
    t.integer "site_id"
    t.integer "created_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "online_payment_allowed"
  end

  create_table "invoice_types", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.integer "created_by_id"
    t.integer "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "issue_types", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "society_id"
    t.string "name"
    t.boolean "active"
  end

  create_table "items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "site_id"
    t.string "name"
    t.text "description"
    t.float "rate"
    t.integer "available_quantity"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active"
    t.integer "group_id"
    t.integer "sub_group_id"
    t.integer "min_stock"
    t.integer "max_stock"
  end

  create_table "job_sheets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "ticket_id"
    t.string "technician"
    t.datetime "scheduled_at"
    t.datetime "check_in_at"
    t.datetime "check_out_at"
    t.text "work_notes"
    t.text "materials"
    t.string "status", default: "scheduled"
    t.text "signature"
    t.integer "site_id"
    t.integer "created_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id"], name: "index_job_sheets_on_site_id"
    t.index ["status"], name: "index_job_sheets_on_status"
    t.index ["ticket_id"], name: "index_job_sheets_on_ticket_id"
  end

  create_table "journal_entries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "entry_number", null: false
    t.date "entry_date", null: false
    t.integer "site_id", null: false
    t.integer "unit_id"
    t.string "entry_type"
    t.integer "reference_id"
    t.string "reference_type"
    t.text "narration"
    t.decimal "total_debit", precision: 15, scale: 2, default: "0.0"
    t.decimal "total_credit", precision: 15, scale: 2, default: "0.0"
    t.string "status", default: "draft"
    t.integer "created_by_id"
    t.integer "posted_by_id"
    t.datetime "posted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invoice_number"
    t.datetime "invoice_date"
    t.integer "expense_month"
    t.integer "expense_year"
    t.index ["created_by_id"], name: "index_journal_entries_on_created_by_id"
    t.index ["entry_date"], name: "index_journal_entries_on_entry_date"
    t.index ["reference_id", "reference_type"], name: "index_journal_entries_on_reference_id_and_reference_type"
    t.index ["site_id", "entry_number"], name: "index_journal_entries_on_site_id_and_entry_number", unique: true
    t.index ["site_id"], name: "index_journal_entries_on_site_id"
    t.index ["status"], name: "index_journal_entries_on_status"
    t.index ["unit_id"], name: "index_journal_entries_on_unit_id"
  end

  create_table "journal_entry_lines", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "journal_entry_id", null: false
    t.integer "ledger_id", null: false
    t.string "entry_side", null: false
    t.decimal "amount", precision: 15, scale: 2, null: false
    t.text "description"
    t.integer "unit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entry_side"], name: "index_journal_entry_lines_on_entry_side"
    t.index ["journal_entry_id"], name: "index_journal_entry_lines_on_journal_entry_id"
    t.index ["ledger_id"], name: "index_journal_entry_lines_on_ledger_id"
    t.index ["unit_id"], name: "index_journal_entry_lines_on_unit_id"
  end

  create_table "kitchen_order_tickets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "restaurant_menu_id"
    t.string "item_name"
    t.integer "quantity", default: 1
    t.string "status", default: "pending"
    t.text "notes"
    t.integer "created_by_id"
    t.datetime "sent_at"
    t.datetime "accepted_at"
    t.datetime "preparing_at"
    t.datetime "ready_at"
    t.datetime "served_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_kitchen_order_tickets_on_order_id"
    t.index ["status"], name: "index_kitchen_order_tickets_on_status"
  end

  create_table "knowledge_articles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title"
    t.integer "category_id"
    t.text "body"
    t.text "tags"
    t.string "status", default: "draft"
    t.integer "views", default: 0
    t.integer "helpful", default: 0
    t.integer "not_helpful", default: 0
    t.integer "site_id"
    t.integer "created_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_knowledge_articles_on_category_id"
    t.index ["site_id"], name: "index_knowledge_articles_on_site_id"
    t.index ["status"], name: "index_knowledge_articles_on_status"
  end

  create_table "ledgers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.integer "account_group_id", null: false
    t.integer "site_id", null: false
    t.integer "unit_id"
    t.text "description"
    t.decimal "opening_balance", precision: 15, scale: 2, default: "0.0"
    t.decimal "current_balance", precision: 15, scale: 2, default: "0.0"
    t.string "ledger_type"
    t.boolean "active", default: true
    t.boolean "is_system", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "advance_amount", precision: 15, scale: 2, default: "0.0"
    t.index ["account_group_id"], name: "index_ledgers_on_account_group_id"
    t.index ["code", "site_id"], name: "index_ledgers_on_code_and_site_id", unique: true
    t.index ["site_id"], name: "index_ledgers_on_site_id"
    t.index ["unit_id"], name: "index_ledgers_on_unit_id"
  end

  create_table "likes", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "forum_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "unliked", null: false
    t.string "resource_type"
    t.integer "resource_id"
    t.index ["forum_id"], name: "index_likes_on_forum_id"
    t.index ["resource_type", "resource_id"], name: "index_likes_on_resource_type_and_resource_id"
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "lock_roles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.string "display_name"
    t.string "access_level"
    t.text "access_to"
    t.integer "company_id"
    t.integer "active", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "permissions_hash"
    t.integer "user_id"
    t.text "phases"
    t.text "modules"
    t.string "role_for", default: "pms"
  end

  create_table "lock_user_permissions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "assignor_id"
    t.integer "lock_role_id"
    t.text "permissions_hash"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "access_level"
    t.text "access_to"
    t.text "phases"
    t.text "modules"
    t.integer "account_id"
    t.integer "user_society_id"
    t.integer "user_id"
    t.string "role_for", default: "pms"
    t.string "user_type"
    t.string "status"
    t.datetime "deactivated_at"
    t.integer "urgency_email_enabled", default: 0
    t.boolean "daily_pms_report", default: false
    t.integer "unit_id"
    t.integer "department_id"
    t.integer "status_submitted_by_id"
    t.datetime "status_submitted_at"
    t.string "employee_id"
    t.date "last_working_date"
    t.string "ownership"
    t.string "source_type"
    t.string "designation"
    t.text "seat_category"
    t.integer "user_roaster_id"
    t.integer "user_shift_id"
    t.integer "building_id"
    t.integer "floor_id"
    t.boolean "shift_margin_applicable", default: false
    t.string "work_type"
    t.integer "seat_category_id"
    t.integer "seat_detail_id"
    t.index ["active"], name: "index_lock_user_permissions_on_active"
    t.index ["role_for"], name: "index_lock_user_permissions_on_role_for"
    t.index ["user_id"], name: "index_lock_user_permissions_on_user_id"
    t.index ["user_society_id"], name: "index_lock_user_permissions_on_user_society_id"
  end

  create_table "loi_details", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "loi_type"
    t.string "reference"
    t.date "loi_date"
    t.integer "created_by_id"
    t.integer "billing_address_id"
    t.integer "delivery_address_id"
    t.float "transportation_amount"
    t.float "retention"
    t.float "tds"
    t.float "qc"
    t.string "related_to"
    t.text "terms"
    t.string "is_approved"
    t.integer "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "vendor_id"
    t.integer "payment_tenure"
    t.float "advance_amount"
    t.string "pr_no"
    t.integer "self_id"
    t.string "loi_comments"
  end

  create_table "loi_items", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "loi_detail_id"
    t.integer "item_id"
    t.string "sac_code"
    t.integer "quantity"
    t.integer "standard_unit_id"
    t.float "rate"
    t.float "csgt_rate"
    t.float "csgt_amt"
    t.float "sgst_rate"
    t.float "sgst_amt"
    t.float "igst_rate"
    t.float "igst_amt"
    t.float "tcs_rate"
    t.float "tcs_amt"
    t.float "tax_amt"
    t.float "amount"
    t.float "total_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "expected_date"
  end

  create_table "loi_services", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "service_detail_id"
    t.string "product_description"
    t.float "quantity"
    t.float "rate"
    t.integer "uom"
    t.date "expected_date"
    t.float "amount"
    t.float "total_amount"
    t.string "kind_attention"
    t.string "subject"
    t.text "description"
    t.text "terms_and_conditions"
    t.integer "service_order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "csgt_rate"
    t.float "csgt_amt"
    t.float "sgst_rate"
    t.float "sgst_amt"
    t.float "igst_rate"
    t.float "igst_amt"
    t.float "tcs_rate"
    t.float "tcs_amt"
    t.float "tax_amt"
  end

  create_table "mail_room_inbounds", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "vendor_id"
    t.date "receiving_date"
    t.string "sender"
    t.string "mobile_number"
    t.string "awb_number"
    t.string "company"
    t.text "company_address_1"
    t.text "company_address_2"
    t.string "state"
    t.string "city"
    t.integer "pincode"
    t.string "mail_inbound_type"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "receipant_name"
    t.integer "unit"
    t.integer "department_id"
    t.string "status"
    t.integer "aging"
    t.datetime "collect_on"
    t.integer "collect_by_id"
    t.boolean "mark_as_collected"
    t.string "entity"
  end

  create_table "mail_room_outbounds", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "vendor_id"
    t.date "sending_date"
    t.integer "sender_id"
    t.string "recipient_name"
    t.string "mobile_number"
    t.string "awb_number"
    t.string "recipient_email_id"
    t.text "recipient_address_1"
    t.text "recipient_address_2"
    t.string "state"
    t.string "city"
    t.integer "pincode"
    t.string "mail_outbound_type"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "unit"
    t.string "entity"
    t.integer "collect_by_id"
    t.string "status"
    t.boolean "mark_as_collected"
    t.integer "recieved_by_id"
    t.string "company"
    t.text "company_address_1"
    t.text "company_address_2"
  end

  create_table "meeting_room_bookings", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "book_type"
    t.integer "user_id"
    t.date "booking_date"
    t.string "facility_type"
    t.string "payment_mode"
    t.string "upi"
    t.text "comment"
    t.boolean "booking_status"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "menus", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.integer "site_id"
    t.integer "generic_info_id"
    t.text "description"
    t.integer "hotel_id"
    t.decimal "price", precision: 8, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "category_id"
  end

  create_table "meter_readings", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "meter_id"
    t.decimal "opening", precision: 10
    t.decimal "closing", precision: 10
    t.decimal "consumption", precision: 10
    t.string "parameter"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mom_attendees", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "mom_detail_id"
    t.string "name"
    t.string "organization"
    t.string "role"
    t.string "email"
    t.string "company_tag_name"
    t.integer "attendees_id"
    t.string "attendees_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mom_detail_id"], name: "index_mom_attendees_on_mom_detail_id"
  end

  create_table "mom_details", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "title"
    t.datetime "meeting_date"
    t.integer "created_by_id"
    t.boolean "active"
    t.string "company_tag_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "site_id"
  end

  create_table "mom_tasks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "mom_detail_id"
    t.text "description"
    t.integer "responsible_person_id"
    t.date "target_date"
    t.string "responsible_person_email"
    t.string "responsible_person_type"
    t.string "responsible_person_name"
    t.integer "company_tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mom_detail_id"], name: "index_mom_tasks_on_mom_detail_id"
  end

  create_table "monthly_expenses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "project_id"
    t.integer "year", null: false
    t.integer "month", null: false
    t.string "category", null: false
    t.decimal "amount", precision: 14, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "site_id"
    t.index ["project_id", "year", "month", "category"], name: "idx_cam_monthly_expenses_unique", unique: true
  end

  create_table "notice_users", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "notice_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "read", default: false
    t.datetime "read_at"
    t.boolean "archived", default: false
    t.datetime "archived_at"
  end

  create_table "notices", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "site_id"
    t.string "notice_title"
    t.text "notice_discription"
    t.datetime "expiry_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "shared"
    t.integer "group_id"
    t.boolean "important"
    t.string "status", default: "upcoming"
    t.boolean "send_email"
    t.integer "created_by_id"
    t.boolean "enabled", default: true
  end

  create_table "organizations", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "company_name"
    t.string "entity"
    t.string "site"
    t.string "country"
    t.string "region"
    t.string "state"
    t.string "city"
    t.string "zonr"
    t.boolean "white_label"
    t.string "sub_domain"
    t.string "billing_type"
    t.string "billing_for"
    t.string "billing_term"
    t.float "rate_per_bill"
    t.string "billing_cycle"
    t.date "start_time"
    t.date "end_time"
  end

  create_table "osr_logs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "about"
    t.integer "about_id"
    t.text "comment"
    t.integer "osr_status_id"
    t.integer "user_id"
    t.integer "osr_staff_id"
    t.string "priority"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "rating"
    t.string "current_status"
    t.integer "user_society_id"
    t.index ["about"], name: "index_osr_logs_on_about"
    t.index ["about_id"], name: "index_osr_logs_on_about_id"
  end

  create_table "other_bills", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "vendor_id"
    t.date "bill_date"
    t.string "invoice_number"
    t.string "related_to"
    t.float "tds_percentage"
    t.float "retention_percentage"
    t.string "deduction_remarks"
    t.float "deduction_amount"
    t.float "additional_expenses"
    t.integer "payment_tenure"
    t.float "cgst_rate"
    t.float "cgst_amount"
    t.float "sgst_rate"
    t.float "sgst_amount"
    t.float "igst_rate"
    t.float "igst_amount"
    t.float "tcs_rate"
    t.float "tcs_amount"
    t.float "tax_amount"
    t.float "total_amount"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.string "gst_no"
    t.string "pan_no"
    t.float "amount"
    t.float "base_amount"
    t.float "tds_rate"
    t.float "tds_amount"
  end

  create_table "other_p_amenities", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "other_project_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["other_project_id"], name: "index_other_p_amenities_on_other_project_id"
  end

  create_table "other_projects", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "address"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "contact_us"
  end

  create_table "pantries", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "item_name"
    t.integer "stock"
    t.text "description"
    t.integer "created_by_id"
    t.boolean "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "parking_configurations", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.integer "building_id"
    t.integer "floor_id"
    t.string "vehicle_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_reserved"
    t.integer "reserved_for_user_id"
    t.integer "site_id"
    t.string "zone_type"
    t.string "no_of_parking_allowed"
    t.string "parking_mechanism"
    t.string "no_of_levels"
    t.string "no_of_units"
    t.string "platform_type"
    t.string "stack_type"
    t.string "access_mode"
    t.string "slot_per_stack"
    t.string "maintenance_freq"
  end

  create_table "parking_policies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "who_can_park"
    t.string "max_vechille_per_flat"
    t.string "allowed_vehicle_type"
    t.string "type_of_reservation"
    t.string "payment_type"
    t.string "billing_frequency"
    t.boolean "ev_charging_available"
    t.string "charging_type"
    t.string "ev_charge_location"
    t.string "ev_charge_fee"
    t.string "who_Can_access"
    t.boolean "visitor_parking_allowed"
    t.text "terms_and_condition"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "parking_slots", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "site_id"
    t.integer "start_hr"
    t.integer "start_min"
    t.integer "end_hr"
    t.integer "end_min"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slot_prefix"
    t.boolean "alphanumeric"
    t.string "no_of_slots"
    t.boolean "ev_charging_available"
    t.integer "total_ev_points"
    t.bigint "parking_configurations_id"
    t.index ["parking_configurations_id"], name: "index_parking_slots_on_parking_configurations_id"
  end

  create_table "patrolling_histories", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "user_id"
    t.integer "patrolling_id"
    t.datetime "expected_time"
    t.datetime "actual_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "longitude"
    t.float "latitude"
    t.text "comment"
  end

  create_table "patrollings", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "building_id"
    t.date "start_date"
    t.date "end_date"
    t.time "start_time"
    t.time "end_time"
    t.integer "time_intervals"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "floor_id"
    t.integer "unit_id"
    t.string "specific_times"
    t.string "patrolling_name"
    t.integer "site_id"
    t.float "longitude"
    t.float "latitude"
  end

  create_table "payments", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "resource_id"
    t.string "resource_type"
    t.float "total_amount"
    t.float "paid_amount"
    t.integer "user_id"
    t.string "payment_method"
    t.string "transaction_id"
    t.date "paymen_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_file_name"
    t.string "image_content_type"
    t.bigint "image_file_size"
    t.datetime "image_updated_at"
    t.text "notes"
  end

  create_table "permissions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "role_access_id"
    t.bigint "role_module_id"
    t.boolean "can_create"
    t.boolean "can_view"
    t.boolean "can_update"
    t.boolean "can_delete"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "feature"
    t.index ["role_access_id"], name: "index_permissions_on_role_access_id"
    t.index ["role_module_id"], name: "index_permissions_on_role_module_id"
  end

  create_table "permit_activities", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "permit_id"
    t.integer "activity"
    t.integer "sub_activity"
    t.integer "category_of_hazards"
    t.string "risks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "permit_activity_setups", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "permit_type_id"
    t.string "name"
    t.integer "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.integer "parent_id"
  end

  create_table "permit_entities", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.integer "permit_id"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "site_id"
  end

  create_table "permit_extensions", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "permit_id"
    t.integer "site_id"
    t.text "reason"
    t.date "ext_date"
    t.time "ext_time"
    t.text "assign_to_ids"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "permit_risks", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "permit_type_id"
    t.integer "activity_id"
    t.integer "sub_activity_id"
    t.integer "hazard_category_id"
    t.text "risk_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "risk_name"
  end

  create_table "permit_safety_equipments", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "safety_equipment_name"
    t.integer "permit_type_id"
    t.integer "activity_id"
    t.integer "sub_activity_id"
    t.integer "hazard_category_id"
    t.integer "permit_risk_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "permit_sub_activities", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.bigint "permit_type_id"
    t.bigint "permit_activity_setup_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["permit_activity_setup_id"], name: "index_permit_sub_activities_on_permit_activity_setup_id"
    t.index ["permit_type_id"], name: "index_permit_sub_activities_on_permit_type_id"
  end

  create_table "permit_types", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.integer "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "permits", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.string "contact_number"
    t.integer "site_id"
    t.integer "unit_id"
    t.string "permit_for"
    t.integer "building_id"
    t.integer "floor_id"
    t.integer "room_id"
    t.string "client_specific"
    t.string "entity"
    t.string "copy_to_string"
    t.string "permit_type"
    t.integer "vendor_id"
    t.datetime "issue_date_and_time"
    t.datetime "expiry_date_and_time"
    t.text "comment"
    t.string "permit_status"
    t.boolean "extention_status"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "pet_name"
    t.string "owner_mobile_no"
    t.string "pet_breed"
    t.string "gender"
    t.string "colour"
    t.string "age"
    t.date "dob"
    t.boolean "is_pet_transfered"
    t.boolean "brought"
    t.boolean "stray_pet_adopted"
    t.boolean "whether_brought_from_current_city"
    t.boolean "pet_born_to_owner_dog"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "is_approved"
    t.datetime "approved_at"
    t.string "rejection_reason"
    t.integer "approved_by_id"
    t.index ["approved_by_id"], name: "index_pets_on_approved_by_id"
    t.index ["is_approved"], name: "index_pets_on_is_approved"
  end

  create_table "poll_options", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "content"
    t.bigint "poll_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["poll_id"], name: "index_poll_options_on_poll_id"
  end

  create_table "poll_users", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "poll_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "read", default: false
    t.datetime "read_at"
    t.boolean "archived", default: false
    t.datetime "archived_at"
  end

  create_table "poll_votes", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "poll_user_id"
    t.bigint "poll_id"
    t.bigint "poll_option_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["poll_id"], name: "index_poll_votes_on_poll_id"
    t.index ["poll_option_id"], name: "index_poll_votes_on_poll_option_id"
  end

  create_table "polls", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.date "start_date"
    t.date "end_date"
    t.string "visibility"
    t.integer "target_groups"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "group_id"
    t.string "group_name"
    t.string "share_with"
    t.time "start_time"
    t.time "end_time"
    t.string "shared"
    t.boolean "send_mail"
  end

  create_table "portals", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "icon_url"
    t.string "saml_idp_sso_url"
    t.string "saml_idp_entity_id"
    t.text "saml_idp_cert"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_portals_on_slug", unique: true
  end

  create_table "prime_times", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "amenity_booking_rule_id"
    t.string "start_time"
    t.string "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["amenity_booking_rule_id"], name: "index_prime_times_on_amenity_booking_rule_id"
  end

  create_table "projects", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "city"
    t.string "tower"
    t.integer "pincode"
    t.string "state"
    t.string "flat_no"
    t.string "intercom"
    t.string "ownership"
    t.string "lives_here"
    t.string "is_primary"
    t.string "address_line_one"
    t.string "address_line_two"
    t.string "company_name"
    t.string "entity"
    t.string "site"
    t.string "country"
    t.string "region"
    t.string "zone"
    t.string "white_label"
    t.string "sub_domain"
    t.string "billing_type"
    t.float "rate_per_bill"
    t.string "billing_for"
    t.string "billing_term"
    t.string "billing_cycle"
    t.date "start_date"
    t.date "end_date"
  end

  create_table "purchase_order_items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "purchase_order_id"
    t.integer "ingredient_id"
    t.decimal "quantity", precision: 12, scale: 3, default: "0.0"
    t.decimal "unit_price", precision: 10, scale: 2, default: "0.0"
    t.decimal "total_price", precision: 12, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ingredient_id"], name: "index_purchase_order_items_on_ingredient_id"
    t.index ["purchase_order_id"], name: "index_purchase_order_items_on_purchase_order_id"
  end

  create_table "purchase_orders", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "order_number"
    t.integer "supplier_id"
    t.date "order_date"
    t.string "status", default: "draft"
    t.decimal "total_amount", precision: 12, scale: 2, default: "0.0"
    t.text "notes"
    t.integer "site_id"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_number"], name: "index_purchase_orders_on_order_number", unique: true
    t.index ["site_id"], name: "index_purchase_orders_on_site_id"
    t.index ["status"], name: "index_purchase_orders_on_status"
    t.index ["supplier_id"], name: "index_purchase_orders_on_supplier_id"
  end

  create_table "qr_verifications", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "expected_time", null: false
    t.datetime "valid_till", null: false
    t.integer "generated_by_id", null: false
    t.boolean "checked_in", default: false, null: false
    t.datetime "checked_in_at"
    t.integer "checked_in_by_id"
    t.integer "site_id", null: false
    t.integer "qr_image_id"
    t.string "purpose"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "checked_out", default: false, null: false
    t.datetime "checked_out_at"
    t.integer "checked_out_by_id"
    t.index ["checked_in"], name: "index_qr_verifications_on_checked_in"
    t.index ["checked_out"], name: "index_qr_verifications_on_checked_out"
    t.index ["checked_out_by_id"], name: "index_qr_verifications_on_checked_out_by_id"
    t.index ["code"], name: "index_qr_verifications_on_code", unique: true
    t.index ["expected_time"], name: "index_qr_verifications_on_expected_time"
    t.index ["generated_by_id"], name: "index_qr_verifications_on_generated_by_id"
    t.index ["qr_image_id"], name: "index_qr_verifications_on_qr_image_id"
    t.index ["site_id"], name: "index_qr_verifications_on_site_id"
  end

  create_table "questions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "checklist_id"
    t.string "name"
    t.string "qtype"
    t.string "option1"
    t.string "option2"
    t.string "option3"
    t.string "option4"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "question_mandatory", default: false
    t.boolean "image_mandatory", default: false
    t.string "value_type1"
    t.string "value_type2"
    t.string "value_type3"
    t.string "value_type4"
    t.string "help_text"
    t.string "weightage"
    t.boolean "help_text_enbled"
    t.boolean "rating"
    t.boolean "reading"
    t.integer "group_id"
  end

  create_table "quotation_histories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "quotation_id"
    t.string "action"
    t.string "actor"
    t.datetime "created_at"
    t.index ["quotation_id"], name: "index_quotation_histories_on_quotation_id"
  end

  create_table "quotation_lines", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "quotation_id"
    t.string "description"
    t.integer "qty", default: 1
    t.decimal "rate", precision: 10, default: "0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quotation_id"], name: "index_quotation_lines_on_quotation_id"
  end

  create_table "quotations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "ticket_id"
    t.integer "vendor_id"
    t.decimal "tax_pct", precision: 10, default: "18"
    t.decimal "discount_pct", precision: 10, default: "0"
    t.string "status", default: "draft"
    t.integer "version", default: 1
    t.text "notes"
    t.string "created_by"
    t.integer "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "visited_at"
    t.string "visited_by"
    t.datetime "work_started_at"
    t.datetime "work_completed_at"
    t.text "work_notes"
    t.decimal "total_amount", precision: 12, scale: 2, default: "0.0"
    t.index ["site_id"], name: "index_quotations_on_site_id"
  end

  create_table "rails_push_notifications_apns_apps", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "apns_dev_cert"
    t.text "apns_prod_cert"
    t.boolean "sandbox_mode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rails_push_notifications_gcm_apps", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "gcm_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rails_push_notifications_mpns_apps", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "cert"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rails_push_notifications_notifications", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "destinations"
    t.integer "app_id"
    t.string "app_type"
    t.text "data"
    t.text "results"
    t.integer "success"
    t.integer "failed"
    t.boolean "sent", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["app_id", "app_type", "sent"], name: "app_and_sent_index_on_rails_push_notifications"
  end

  create_table "receipt_setups", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "prefix"
    t.integer "next_number"
    t.boolean "auto_generate"
    t.string "receipt_number"
    t.integer "created_by"
    t.integer "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "receipts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "bill_type", null: false
    t.bigint "bill_id", null: false
    t.decimal "amount", precision: 14, scale: 2, null: false
    t.date "date", null: false
    t.string "reference_no"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bill_type", "bill_id"], name: "index_receipts_on_bill_type_and_bill_id"
  end

  create_table "registered_vehicle_visits", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "registered_vehicle_id"
    t.datetime "check_in"
    t.datetime "check_out"
    t.integer "site_id"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "no_of_people"
    t.index ["registered_vehicle_id"], name: "index_registered_vehicle_visits_on_registered_vehicle_id"
  end

  create_table "registered_vehicles", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "slot_number"
    t.string "vehicle_category"
    t.string "vehicle_type"
    t.string "sticker_number"
    t.string "registration_number"
    t.string "insurance_number"
    t.date "insurance_valid_till"
    t.string "category"
    t.string "vehicle_number"
    t.integer "unit_id"
    t.integer "user_id"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "status", default: true
    t.integer "site_id"
    t.datetime "valid_till"
    t.string "approved", default: "Pending"
    t.string "vehicle_in_out"
    t.index ["vehicle_in_out"], name: "index_registered_vehicles_on_vehicle_in_out"
  end

  create_table "restaurant_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "food_and_beverage_id", null: false
    t.string "name", null: false
    t.boolean "custom", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["food_and_beverage_id"], name: "index_restaurant_categories_on_food_and_beverage_id"
  end

  create_table "restaurant_cuisines", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "food_and_beverage_id", null: false
    t.string "name", null: false
    t.boolean "custom", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["food_and_beverage_id"], name: "index_restaurant_cuisines_on_food_and_beverage_id"
  end

  create_table "restaurant_floors", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "food_and_beverage_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["food_and_beverage_id"], name: "index_restaurant_floors_on_food_and_beverage_id"
  end

  create_table "restaurant_menus", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "restaurant_id"
    t.string "name"
    t.string "sku"
    t.float "price"
    t.boolean "active"
    t.integer "category_id"
    t.integer "sub_category_id"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "master_price"
    t.string "category_name"
    t.boolean "selected", default: true
    t.integer "prep_time", default: 15
    t.string "spice_level", default: "Medium"
    t.boolean "is_favorite", default: false
    t.index ["restaurant_id"], name: "index_restaurant_menus_on_restaurant_id"
  end

  create_table "restaurant_order_items", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "order_id"
    t.integer "restaurant_menu_id"
    t.integer "quantity"
    t.float "amount"
    t.float "rate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "restaurant_orders", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "restaurant_id"
    t.date "ondate"
    t.time "ontime"
    t.integer "user_id"
    t.string "payment_status"
    t.float "total_amount"
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.string "table_number"
    t.integer "booking_id"
    t.string "order_type", default: "dine-in"
    t.string "customer_name"
    t.string "customer_phone"
    t.text "customer_address"
    t.float "service_charge", default: 0.0
    t.float "tax_amount", default: 0.0
    t.float "discount", default: 0.0
    t.float "paid_amount", default: 0.0
    t.string "payment_mode"
    t.datetime "billed_at"
    t.datetime "completed_at"
    t.string "confirm_token"
    t.datetime "confirmed_at"
    t.integer "restaurant_table_id"
    t.string "table_name"
    t.string "razorpay_order_id"
    t.string "razorpay_payment_id"
    t.datetime "paid_at"
    t.text "payment_failure_reason"
    t.decimal "refund_amount", precision: 12, scale: 2
    t.datetime "refunded_at"
    t.float "delivery_charges"
    t.float "convenience_fee"
    t.index ["booking_id"], name: "index_restaurant_orders_on_booking_id"
    t.index ["confirm_token"], name: "index_restaurant_orders_on_confirm_token", unique: true
    t.index ["order_type"], name: "index_restaurant_orders_on_order_type"
    t.index ["restaurant_table_id"], name: "index_restaurant_orders_on_restaurant_table_id"
  end

  create_table "restaurant_tables", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "food_and_beverage_id", null: false
    t.integer "restaurant_floor_id"
    t.string "name"
    t.integer "capacity", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["food_and_beverage_id"], name: "index_restaurant_tables_on_food_and_beverage_id"
    t.index ["restaurant_floor_id"], name: "index_restaurant_tables_on_restaurant_floor_id"
  end

  create_table "role_accesses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title"
    t.bigint "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id"], name: "index_role_accesses_on_site_id"
  end

  create_table "role_modules", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "room_availabilities", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "room_id", null: false
    t.date "date", null: false
    t.boolean "is_available", default: true
    t.string "unavailable_reason"
    t.decimal "special_price", precision: 10, scale: 2
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date", "is_available"], name: "index_room_availabilities_on_date_and_is_available"
    t.index ["room_id", "date"], name: "index_room_availabilities_on_room_id_and_date", unique: true
    t.index ["room_id"], name: "index_room_availabilities_on_room_id"
  end

  create_table "room_bookings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "room_id", null: false
    t.bigint "user_id", null: false
    t.bigint "site_id", null: false
    t.string "booking_reference", null: false
    t.date "check_in_date", null: false
    t.date "check_out_date", null: false
    t.integer "number_of_nights", null: false
    t.integer "adults_count", default: 1
    t.integer "children_count", default: 0
    t.decimal "room_rate_per_night", precision: 10, scale: 2, null: false
    t.decimal "total_room_charges", precision: 10, scale: 2, null: false
    t.decimal "tax_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "total_amount", precision: 10, scale: 2, null: false
    t.string "status", default: "pending"
    t.text "special_requests"
    t.text "guest_details"
    t.string "contact_phone"
    t.string "contact_email"
    t.datetime "booking_date"
    t.datetime "confirmed_at"
    t.datetime "cancelled_at"
    t.text "cancellation_reason"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_reference"], name: "index_room_bookings_on_booking_reference", unique: true
    t.index ["check_in_date", "check_out_date"], name: "index_room_bookings_on_check_in_date_and_check_out_date"
    t.index ["room_id", "check_in_date", "check_out_date"], name: "idx_room_bookings_room_and_dates"
    t.index ["site_id", "status"], name: "index_room_bookings_on_site_id_and_status"
    t.index ["site_id"], name: "index_room_bookings_on_site_id"
    t.index ["user_id", "status"], name: "index_room_bookings_on_user_id_and_status"
    t.index ["user_id"], name: "index_room_bookings_on_user_id"
  end

  create_table "room_pricings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "room_id", null: false
    t.date "effective_date", null: false
    t.date "end_date"
    t.decimal "price_per_night", precision: 10, scale: 2, null: false
    t.decimal "weekend_price", precision: 10, scale: 2
    t.decimal "holiday_price", precision: 10, scale: 2
    t.string "pricing_type", default: "regular"
    t.text "description"
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_id", "effective_date"], name: "index_room_pricings_on_room_id_and_effective_date"
    t.index ["room_id", "pricing_type"], name: "index_room_pricings_on_room_id_and_pricing_type"
    t.index ["room_id"], name: "index_room_pricings_on_room_id"
  end

  create_table "rooms", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "room_number", null: false
    t.text "description"
    t.string "room_type"
    t.decimal "price_per_night", precision: 10, scale: 2, null: false
    t.decimal "tax_percentage", precision: 5, scale: 2, default: "0.0"
    t.integer "max_adults", default: 2
    t.integer "max_children", default: 0
    t.integer "total_capacity"
    t.decimal "room_size", precision: 8, scale: 2
    t.string "bed_type"
    t.text "amenities"
    t.text "special_features"
    t.boolean "is_active", default: true
    t.boolean "is_available", default: true
    t.bigint "site_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id", "is_active"], name: "index_rooms_on_site_id_and_is_active"
    t.index ["site_id", "room_number"], name: "index_rooms_on_site_id_and_room_number", unique: true
    t.index ["site_id", "room_type"], name: "index_rooms_on_site_id_and_room_type"
    t.index ["site_id"], name: "index_rooms_on_site_id"
  end

  create_table "saml_temp_tokens", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_saml_temp_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_saml_temp_tokens_on_user_id"
  end

  create_table "saved_forums", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "forum_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["forum_id"], name: "index_saved_forums_on_forum_id"
    t.index ["user_id", "forum_id"], name: "index_saved_forums_on_user_id_and_forum_id", unique: true
    t.index ["user_id"], name: "index_saved_forums_on_user_id"
  end

  create_table "seat_bookings", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "book_type"
    t.integer "user_id"
    t.date "booking_date"
    t.integer "building_id"
    t.integer "floor_id"
    t.boolean "booking_status"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "site_id"
  end

  create_table "seats", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "buiding_id"
    t.integer "floor_id"
    t.integer "unit_id"
    t.string "seat"
    t.integer "no"
    t.integer "category_id"
    t.integer "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "service_bookings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "booking_date", null: false
    t.string "status", default: "pending"
    t.text "special_instructions"
    t.text "cancellation_reason"
    t.datetime "cancelled_at"
    t.decimal "total_amount", precision: 10, scale: 2
    t.decimal "discount_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "tax_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "final_amount", precision: 10, scale: 2
    t.string "payment_status", default: "pending"
    t.string "payment_method"
    t.string "transaction_id"
    t.datetime "service_started_at"
    t.datetime "service_completed_at"
    t.integer "rating"
    t.text "feedback"
    t.bigint "user_id", null: false
    t.bigint "unit_id", null: false
    t.bigint "service_subcategory_id", null: false
    t.bigint "service_slot_id", null: false
    t.bigint "service_pricing_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "unit_configuration_id"
    t.index ["service_pricing_id"], name: "index_service_bookings_on_service_pricing_id"
    t.index ["service_slot_id"], name: "index_service_bookings_on_service_slot_id"
    t.index ["service_subcategory_id"], name: "index_service_bookings_on_service_subcategory_id"
    t.index ["unit_configuration_id"], name: "index_service_bookings_on_unit_configuration_id"
    t.index ["unit_id"], name: "index_service_bookings_on_unit_id"
    t.index ["user_id", "booking_date"], name: "index_service_bookings_on_user_id_and_booking_date"
    t.index ["user_id"], name: "index_service_bookings_on_user_id"
  end

  create_table "service_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "icon_url"
    t.integer "sort_order", default: 0
    t.boolean "active", default: true
    t.bigint "site_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id", "name"], name: "index_service_categories_on_site_id_and_name", unique: true
    t.index ["site_id", "sort_order"], name: "index_service_categories_on_site_id_and_sort_order"
    t.index ["site_id"], name: "index_service_categories_on_site_id"
  end

  create_table "service_orders", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.datetime "service_order_date"
    t.integer "billing_address_id"
    t.float "retention"
    t.float "tds"
    t.float "qc"
    t.float "payment_tenure"
    t.float "advance_amount"
    t.string "related_to"
    t.integer "site_id"
    t.integer "vendor_id"
    t.integer "created_by_id"
    t.string "reference"
    t.boolean "active"
    t.boolean "approved_status"
    t.float "total_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "pr_no"
    t.string "kind_attention"
    t.string "subject"
    t.text "description"
    t.text "terms_and_conditions"
  end

  create_table "service_pricings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.decimal "price", precision: 10, scale: 2, null: false
    t.decimal "discount_percentage", precision: 5, scale: 2, default: "0.0"
    t.decimal "tax_percentage", precision: 5, scale: 2, default: "0.0"
    t.boolean "active", default: true
    t.bigint "service_subcategory_id", null: false
    t.bigint "unit_configuration_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "discount_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "tax_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "final_price", precision: 10, scale: 2, default: "0.0"
    t.index ["service_subcategory_id", "unit_configuration_id"], name: "index_service_pricings_on_subcategory_and_unit_config", unique: true
    t.index ["service_subcategory_id"], name: "index_service_pricings_on_service_subcategory_id"
    t.index ["unit_configuration_id"], name: "index_service_pricings_on_unit_configuration_id"
  end

  create_table "service_slots", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.time "start_time"
    t.time "end_time"
    t.integer "max_bookings", default: 1
    t.boolean "active", default: true
    t.bigint "service_subcategory_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "start_hr"
    t.integer "end_hr"
    t.integer "start_min"
    t.integer "end_min"
    t.index ["service_subcategory_id", "start_time"], name: "index_service_slots_on_service_subcategory_id_and_start_time", unique: true
    t.index ["service_subcategory_id"], name: "index_service_slots_on_service_subcategory_id"
  end

  create_table "service_subcategories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.text "terms_and_conditions"
    t.integer "duration_minutes"
    t.integer "advance_booking_hours", default: 24
    t.integer "cancellation_hours", default: 4
    t.integer "sort_order", default: 0
    t.boolean "active", default: true
    t.bigint "service_category_id", null: false
    t.bigint "site_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service_category_id", "name"], name: "index_service_subcategories_on_service_category_id_and_name", unique: true
    t.index ["service_category_id"], name: "index_service_subcategories_on_service_category_id"
    t.index ["site_id", "active"], name: "index_service_subcategories_on_site_id_and_active"
    t.index ["site_id"], name: "index_service_subcategories_on_site_id"
  end

  create_table "share_withs", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "user_id"
    t.integer "shared_by"
    t.integer "folder_id"
    t.integer "document_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shared_forums", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.bigint "forum_id", null: false
    t.bigint "sender_id", null: false
    t.bigint "receiver_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["forum_id"], name: "index_shared_forums_on_forum_id"
    t.index ["receiver_id"], name: "index_shared_forums_on_receiver_id"
    t.index ["sender_id"], name: "index_shared_forums_on_sender_id"
  end

  create_table "site_assets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "site_id"
    t.integer "building_id"
    t.integer "floor_id"
    t.integer "unit_id"
    t.string "name"
    t.string "serial_number"
    t.string "model_number"
    t.date "purchased_on"
    t.float "purchase_cost"
    t.date "warranty_expiry"
    t.integer "user_id"
    t.boolean "critical"
    t.boolean "breakdown"
    t.boolean "is_meter"
    t.integer "parent_asset_id"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.string "oem_name"
    t.string "capacity"
    t.date "installation"
    t.date "warranty_start"
    t.text "remarks"
    t.integer "vendor_id"
    t.integer "asset_group_id"
    t.string "uom"
    t.string "asset_type"
    t.integer "asset_sub_group_id"
    t.string "equipemnt_id"
    t.string "asset_number"
    t.integer "asset_meter_type_id"
    t.float "latitude"
    t.float "longitude"
    t.boolean "comprehensive"
    t.string "category", default: "general"
    t.json "category_data"
    t.json "custom_sections"
    t.index ["category"], name: "index_site_assets_on_category"
  end

  create_table "site_modules", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "site_id"
    t.bigint "role_modules_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_modules_id"], name: "index_site_modules_on_role_modules_id"
    t.index ["site_id"], name: "index_site_modules_on_site_id"
  end

  create_table "sites", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "region"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.float "longitude"
    t.float "latitude"
    t.integer "radius"
    t.string "account_id"
    t.string "lotus_ble_key"
    t.string "city"
    t.string "address"
    t.string "site_code"
    t.integer "project_id"
    t.string "country"
    t.date "activation_date"
    t.string "site_owner"
    t.string "phone_no"
    t.string "email_address"
    t.string "selected_product"
    t.index ["account_id"], name: "index_sites_on_account_id", unique: true
  end

  create_table "snag_answers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "question_id"
    t.integer "quest_option_id"
    t.string "ans_descr"
    t.text "comments"
    t.integer "user_id"
    t.integer "company_id"
    t.integer "checklist_id"
    t.string "answer_type"
    t.string "answer_mode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "resource_id"
    t.string "resource_type"
  end

  create_table "snag_checklists", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.integer "snag_audit_category_id"
    t.integer "snag_audit_sub_category_id"
    t.integer "active"
    t.integer "site_id"
    t.integer "company_id"
    t.string "check_type"
    t.integer "user_id"
    t.integer "resource_id"
    t.string "resource_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "snag_quest_options", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "question_id"
    t.string "qname"
    t.integer "active"
    t.integer "company_id"
    t.string "option_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "snag_question_id"
  end

  create_table "snag_questions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "qtype"
    t.text "descr"
    t.integer "checklist_id"
    t.integer "user_id"
    t.boolean "img_mandatory"
    t.boolean "quest_mandatory"
    t.integer "active"
    t.integer "company_id"
    t.integer "qnumber"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "snag_checklist_id"
  end

  create_table "soft_services", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "site_id"
    t.integer "building_id"
    t.integer "floor_id"
    t.text "unit_id"
    t.string "name"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "generic_info_id"
    t.integer "generic_sub_info_id"
    t.float "longitude"
    t.float "latitude"
  end

  create_table "staff_units", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "staff_id"
    t.bigint "unit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["staff_id"], name: "index_staff_units_on_staff_id"
    t.index ["unit_id"], name: "index_staff_units_on_unit_id"
  end

  create_table "staffs", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "firstname"
    t.string "lastname"
    t.string "email"
    t.string "mobile_no"
    t.integer "unit_id"
    t.string "work_type"
    t.integer "vendor_id"
    t.datetime "valid_from"
    t.datetime "valid_till"
    t.boolean "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "working_schedule", limit: 4294967295, collation: "utf8mb4_bin"
    t.integer "site_id"
    t.float "longitude"
    t.float "latitude"
    t.string "staff_id"
    t.string "status_type", default: "Pending"
    t.integer "created_by_id"
    t.text "embedding"
    t.date "date_of_birth"
    t.string "staff_in_out"
    t.date "joining_date"
    t.index ["staff_id"], name: "index_staffs_on_staff_id", unique: true
  end

  create_table "standard_units", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "unit_name"
    t.string "convention"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "status_restaurants", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "status"
    t.string "display_name"
    t.integer "fixed_state"
    t.integer "order"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "site_id"
  end

  create_table "sub_groups", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "group_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "submissions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "asset_id"
    t.integer "checklist_id"
    t.integer "activity_id"
    t.integer "question_id"
    t.string "value"
    t.text "comment"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "asset_param_id"
    t.integer "soft_service_id"
    t.integer "patrolling_id"
    t.index ["activity_id", "asset_param_id"], name: "index_submissions_on_activity_id_and_asset_param_id"
    t.index ["activity_id"], name: "index_submissions_on_activity_id"
    t.index ["asset_param_id"], name: "index_submissions_on_asset_param_id"
    t.index ["created_at"], name: "index_submissions_on_created_at"
  end

  create_table "suppliers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "contact_person"
    t.string "email"
    t.string "phone"
    t.text "address"
    t.boolean "status", default: true
    t.integer "site_id"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id"], name: "index_suppliers_on_site_id"
    t.index ["status"], name: "index_suppliers_on_status"
  end

  create_table "survey_answers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "survey_response_id"
    t.bigint "survey_question_id"
    t.text "text_value"
    t.integer "numeric_value"
    t.json "selected_option_ids"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["survey_question_id"], name: "index_survey_answers_on_survey_question_id"
    t.index ["survey_response_id"], name: "index_survey_answers_on_survey_response_id"
  end

  create_table "survey_question_options", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "survey_question_id"
    t.string "label"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["survey_question_id"], name: "index_survey_question_options_on_survey_question_id"
  end

  create_table "survey_questions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "survey_id"
    t.string "q_title"
    t.string "question_type"
    t.integer "position"
    t.boolean "required"
    t.integer "min_value"
    t.integer "max_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["survey_id"], name: "index_survey_questions_on_survey_id"
  end

  create_table "survey_responses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "survey_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "company_name"
    t.string "floor_unit"
    t.date "feedback_date"
    t.string "feedback_given_by"
    t.string "contact_details"
    t.string "respond_mail"
    t.index ["survey_id"], name: "index_survey_responses_on_survey_id"
    t.index ["user_id"], name: "index_survey_responses_on_user_id"
  end

  create_table "surveys", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "survey_title"
    t.datetime "start_date"
    t.datetime "end_date"
    t.text "description"
    t.integer "created_by_id"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "id_of_site"
    t.string "extra"
    t.string "background_color"
    t.text "header_text"
    t.text "footer_text"
    t.string "theme_color"
    t.text "invitation_message"
    t.text "thank_you_message"
  end

  create_table "system_logs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "log_of"
    t.integer "log_of_id"
    t.text "changed_attr"
    t.integer "changed_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "about"
    t.integer "about_id"
    t.string "log_type"
    t.integer "question_id"
    t.integer "room_type_id"
    t.index ["log_of"], name: "index_system_logs_on_log_of"
    t.index ["log_of_id"], name: "index_system_logs_on_log_of_id"
    t.index ["question_id"], name: "question_id"
    t.index ["room_type_id"], name: "room_type_id"
  end

  create_table "table_bookings", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "restaurant_id"
    t.date "ondate"
    t.time "ontime"
    t.integer "user_id"
    t.integer "no_of_person"
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "restaurant_table_id"
    t.string "contact_number"
    t.string "customer_name"
    t.text "notes"
    t.index ["restaurant_id"], name: "index_table_bookings_on_restaurant_id"
    t.index ["restaurant_table_id"], name: "index_table_bookings_on_restaurant_table_id"
  end

  create_table "tasks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "project_id"
    t.string "name"
    t.date "tat"
    t.integer "priority"
    t.integer "status"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "resource_id"
    t.string "resource_type"
  end

  create_table "tax_rates", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "tax_type", null: false
    t.decimal "rate", precision: 5, scale: 2, null: false
    t.integer "site_id"
    t.integer "ledger_id"
    t.text "description"
    t.boolean "active", default: true
    t.date "effective_from"
    t.date "effective_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_tax_rates_on_active"
    t.index ["ledger_id"], name: "index_tax_rates_on_ledger_id"
    t.index ["site_id"], name: "index_tax_rates_on_site_id"
    t.index ["tax_type"], name: "index_tax_rates_on_tax_type"
  end

  create_table "tenant_charges", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "unit_id", null: false
    t.string "charge_type", null: false
    t.decimal "base_amount", precision: 14, scale: 2, null: false
    t.decimal "gst_rate_percent", precision: 5, scale: 2, null: false
    t.decimal "gst_amount", precision: 14, scale: 2, null: false
    t.decimal "total_amount", precision: 14, scale: 2, null: false
    t.date "date", null: false
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_tenant_charges_on_date"
    t.index ["unit_id"], name: "index_tenant_charges_on_unit_id"
  end

  create_table "ticket_items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "ticket_id"
    t.integer "item_id"
    t.float "rate"
    t.integer "item_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ticket_logs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "ticket_id"
    t.integer "created_by_id"
    t.string "status"
    t.string "log_type"
    t.text "remarks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tickets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "site_id"
    t.integer "category_id"
    t.integer "sub_category_id"
    t.string "status"
    t.text "description"
    t.integer "created_by_id"
    t.integer "assigned_to_id"
    t.float "total_cost"
    t.integer "tm_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tmp_checklists", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "site_id"
    t.string "frequency"
    t.integer "user_id"
    t.string "tmp_name"
    t.string "occurs"
    t.string "ctype"
    t.integer "patrolling_id"
    t.boolean "weightage_enabled"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "todo_lists", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title"
    t.string "status"
    t.integer "relation_id"
    t.string "relation"
    t.integer "site_id"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "assigned_to"
    t.string "task_type"
    t.boolean "urgent"
    t.boolean "repeat"
    t.date "to_from"
    t.date "to_date"
    t.integer "time"
    t.json "working_days"
    t.datetime "due_date"
    t.text "task_description"
    t.json "dependent_task_ids"
  end

  create_table "transport_requests", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "employee_name"
    t.integer "employee_id"
    t.string "pickup_location"
    t.datetime "date_and_time"
    t.text "special_requirements"
    t.text "driver_contact_information"
    t.text "vehicle_details"
    t.integer "booking_confirmation_number"
    t.string "booking_status"
    t.boolean "manager_approval"
    t.string "booking_confirmation_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "mobile_no"
    t.date "start_date"
    t.date "end_date"
    t.string "drop_off_location"
  end

  create_table "transportation_allowance_requests", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "employee_name"
    t.integer "employee_id"
    t.string "expense_category"
    t.date "date_of_expense"
    t.text "description_of_expense"
    t.float "amount_spent"
    t.string "approval_status"
    t.float "reimbursement_amount"
    t.string "reimbursement_method"
    t.boolean "manager_approval"
    t.string "reimbursement_confirmation_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "mobile_no"
  end

  create_table "transportations", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "on_behalf_of"
    t.string "pickup_location"
    t.string "dropoff_location"
    t.date "date"
    t.time "time"
    t.integer "no_of_passengers"
    t.text "additional_note"
    t.string "transportation_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "site_id"
    t.integer "on_behalf_id"
    t.string "mobile_no"
    t.integer "user_id"
    t.integer "created_by_id"
    t.index ["created_by_id"], name: "index_transportations_on_created_by_id"
    t.index ["user_id"], name: "index_transportations_on_user_id"
  end

  create_table "travel_allowance_requests", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "employee_id"
    t.string "employee_name"
    t.string "expense_category"
    t.date "date_of_expense"
    t.decimal "amount_spent", precision: 10
    t.string "approval_status"
    t.decimal "reimbursement_amount", precision: 10
    t.string "reimbursement_method"
    t.boolean "manager_approval"
    t.string "reimbursement_confirmation_email"
    t.text "description_of_expense"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "mobile_no"
  end

  create_table "unit_cam_configs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "unit_id", null: false
    t.decimal "carpet_area_sqft", precision: 12, scale: 3, default: "0.0", null: false
    t.date "cam_start_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "advance_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.index ["cam_start_date"], name: "index_unit_cam_configs_on_cam_start_date"
    t.index ["unit_id"], name: "index_unit_cam_configs_on_unit_id", unique: true
  end

  create_table "unit_configurations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.integer "bedrooms"
    t.integer "bathrooms"
    t.integer "halls"
    t.integer "kitchens"
    t.decimal "carpet_area", precision: 8, scale: 2
    t.decimal "built_up_area", precision: 8, scale: 2
    t.boolean "active", default: true
    t.bigint "site_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id", "name"], name: "index_unit_configurations_on_site_id_and_name", unique: true
    t.index ["site_id"], name: "index_unit_configurations_on_site_id"
  end

  create_table "units", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.integer "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "building_id"
    t.integer "floor_id"
    t.bigint "unit_configuration_id"
    t.string "invoice_number"
    t.index ["unit_configuration_id"], name: "index_units_on_unit_configuration_id"
  end

  create_table "user_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_devices", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "device_id"
    t.string "device_type"
    t.string "gcm_key"
    t.string "device_name"
    t.string "device_os_version"
    t.integer "app_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "full_screen", default: true
    t.boolean "call"
    t.string "ios_sound"
  end

  create_table "user_members", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "member_type"
    t.string "member_name"
    t.string "contact_no"
    t.string "relation"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_members_on_user_id"
  end

  create_table "user_portal_accesses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "portal_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["portal_id"], name: "index_user_portal_accesses_on_portal_id"
    t.index ["user_id", "portal_id"], name: "index_user_portal_accesses_on_user_id_and_portal_id", unique: true
    t.index ["user_id"], name: "index_user_portal_accesses_on_user_id"
  end

  create_table "user_refferals", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "from_user_id"
    t.integer "to_user_id"
    t.string "name"
    t.string "mobile"
    t.string "email"
    t.string "business"
    t.string "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "date_time"
    t.string "refferal_type"
    t.boolean "deleted", default: false
  end

  create_table "user_sites", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "site_id"
    t.boolean "is_current"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "build_id"
    t.integer "unit_id"
    t.boolean "lives_here"
    t.string "ownership"
    t.string "ownership_type"
    t.boolean "is_approved"
    t.integer "floor_id"
  end

  create_table "user_vendors", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "service_type"
    t.string "name"
    t.string "contact_no"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_vendors_on_user_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "firstname", default: "", null: false
    t.string "lastname", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.string "api_key"
    t.string "user_type"
    t.integer "company_id"
    t.string "mobile"
    t.integer "unit_id"
    t.integer "current_site_id"
    t.boolean "face_added"
    t.string "user_face_url"
    t.boolean "active", default: true
    t.string "user_courtesy"
    t.string "user_phase"
    t.boolean "user_status"
    t.integer "building_id"
    t.integer "user_category_id"
    t.text "user_address"
    t.boolean "resident_type"
    t.boolean "membership_type"
    t.boolean "lives_here"
    t.boolean "allow_fitout"
    t.date "birth_date"
    t.date "anniversary"
    t.date "spouse_birth_date"
    t.string "email_1"
    t.string "email_2"
    t.string "landline_number"
    t.string "intercom_number"
    t.integer "gst_number"
    t.integer "pan_number"
    t.string "ev_connection"
    t.integer "no_of_adults"
    t.integer "no_of_childrens"
    t.integer "no_of_pets"
    t.boolean "differently_abled"
    t.integer "department_id"
    t.integer "manager_id"
    t.text "about_me"
    t.string "position"
    t.string "connection"
    t.integer "organization_id"
    t.string "profile_image_file_name"
    t.string "profile_image_content_type"
    t.bigint "profile_image_file_size"
    t.datetime "profile_image_updated_at"
    t.boolean "delete_request"
    t.boolean "lad_long_required", default: true
    t.integer "vendor_id"
    t.string "otp"
    t.string "rotary_club"
    t.datetime "wedding_date"
    t.string "business_name"
    t.string "business_category"
    t.string "education_qualification"
    t.string "office_address"
    t.integer "rbm_by_id"
    t.boolean "member_of_rmb"
    t.string "facebook_link"
    t.string "instagram_link"
    t.string "linkedin_profile"
    t.datetime "date_of_joining"
    t.string "blood_group"
    t.datetime "otp_sent_at"
    t.datetime "moving_date"
    t.string "profession"
    t.string "mgl_customer_number"
    t.string "adani_electricity_account_no"
    t.string "net_provider_name"
    t.string "net_provider_id"
    t.integer "floor_id"
    t.boolean "is_admin_approved"
    t.integer "created_by_id"
    t.date "start_date"
    t.date "end_date"
    t.text "lotus_token"
    t.string "sso_uid"
    t.string "sso_provider"
    t.string "microsoft_uid"
    t.text "encrypted_microsoft_access_token"
    t.string "encrypted_microsoft_access_token_iv"
    t.text "encrypted_microsoft_refresh_token"
    t.string "encrypted_microsoft_refresh_token_iv"
    t.datetime "microsoft_token_expires_at"
    t.integer "helpdesk_category_id"
    t.integer "helpdesk_sub_category_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["helpdesk_category_id"], name: "index_users_on_helpdesk_category_id"
    t.index ["helpdesk_sub_category_id"], name: "index_users_on_helpdesk_sub_category_id"
    t.index ["microsoft_uid"], name: "index_users_on_microsoft_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["sso_uid", "sso_provider"], name: "index_users_on_sso_uid_and_provider", unique: true
  end

  create_table "vehicle_details", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "user_id"
    t.string "vehicle_type"
    t.string "vehicle_no"
    t.string "parking_slot_no"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_vehicle_details_on_user_id"
  end

  create_table "vehicle_setups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "vehicle_category"
    t.string "vehicle_type_name"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "vendors", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "vendor_name"
    t.string "company_name"
    t.string "mobile"
    t.string "email"
    t.integer "site_id"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "secondary_mobile"
    t.string "secondary_email"
    t.string "gstin_number"
    t.string "pan_number"
    t.text "address"
    t.boolean "active", default: true
    t.string "country"
    t.string "state"
    t.string "city"
    t.string "pincode"
    t.text "address2"
    t.string "account_name"
    t.string "account_number"
    t.string "bank_branch_name"
    t.string "ifsc_code"
    t.string "website_url"
    t.string "district"
    t.bigint "vendor_supplier_id"
    t.bigint "vendor_categories_id"
    t.string "website_link"
    t.date "aggrement_start_date"
    t.date "aggremenet_end_date"
    t.string "spoc_person"
    t.string "status"
    t.index ["vendor_categories_id"], name: "index_vendors_on_vendor_categories_id"
    t.index ["vendor_supplier_id"], name: "index_vendors_on_vendor_supplier_id"
  end

  create_table "visitor_alert_configs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "site_id"
    t.boolean "enabled", default: false
    t.integer "threshold_value", default: 4
    t.string "threshold_unit", default: "hours"
    t.datetime "last_alert_sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id"], name: "index_visitor_alert_configs_on_site_id", unique: true
  end

  create_table "visitor_cards", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "company_code"
    t.string "tag_type"
    t.string "status"
    t.json "card_data"
    t.string "card_id"
    t.bigint "visitor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id", "visitor_id"], name: "index_visitor_cards_on_card_id_and_visitor_id", unique: true
    t.index ["visitor_id"], name: "index_visitor_cards_on_visitor_id"
  end

  create_table "visitor_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "site_id"
  end

  create_table "visitor_device_logs", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "employee_no"
    t.string "name"
    t.datetime "in_time"
    t.datetime "out_time"
    t.integer "door_no"
    t.integer "device_serial_no"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_no", "in_time", "out_time"], name: "index_unique_visitor_logs", unique: true
  end

  create_table "visitor_group_invite_guests", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "visitor_group_invite_id"
    t.string "mobile_number"
    t.string "invitation_token"
    t.integer "vhost_id"
    t.integer "visitor_id"
    t.string "name"
    t.string "email"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invitation_token"], name: "index_visitor_group_invite_guests_on_invitation_token", unique: true
    t.index ["vhost_id"], name: "index_visitor_group_invite_guests_on_vhost_id"
    t.index ["visitor_group_invite_id"], name: "index_vg_invite_guests_on_vg_invite_id"
    t.index ["visitor_id"], name: "index_visitor_group_invite_guests_on_visitor_id"
  end

  create_table "visitor_group_invites", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "site_id"
    t.integer "invited_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invited_by_id"], name: "index_visitor_group_invites_on_invited_by_id"
    t.index ["site_id"], name: "index_visitor_group_invites_on_site_id"
  end

  create_table "visitor_sub_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "visitor_category_id"
    t.string "name"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["visitor_category_id"], name: "index_visitor_sub_categories_on_visitor_category_id"
  end

  create_table "visitor_visits", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "visitor_id"
    t.datetime "check_in"
    t.datetime "check_out"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_deleted", default: false
  end

  create_table "visitors", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.string "contact_no"
    t.text "purpose"
    t.integer "site_id"
    t.integer "otp"
    t.boolean "status"
    t.datetime "start_pass"
    t.datetime "end_pass"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.string "coming_from"
    t.string "vehicle_number"
    t.date "expected_date"
    t.time "expected_time"
    t.boolean "skip_host_approval", default: false
    t.boolean "goods_inwards", default: false
    t.string "visit_type"
    t.string "frequency"
    t.text "working_days"
    t.string "pass_number"
    t.bigint "visitor_staff_category_id"
    t.integer "parking_slot"
    t.string "visitor_in_out"
    t.integer "vhost_id"
    t.boolean "verified", default: false
    t.date "pass_start_date"
    t.date "pass_end_date"
    t.integer "building_id"
    t.integer "unit_id"
    t.integer "floor_id"
    t.integer "parent_id"
    t.boolean "driving_license"
    t.boolean "consignment_form"
    t.string "qr_token"
    t.datetime "qr_generated_at"
    t.datetime "qr_first_scanned_at"
    t.datetime "qr_expires_at"
    t.string "qr_status", default: "active"
    t.string "qr_token_digest"
    t.integer "qr_pending_expiry_minutes"
    t.datetime "qr_checked_in_at"
    t.boolean "is_deleted", default: false
    t.text "embedding"
    t.text "lotus_token"
    t.date "start_date"
    t.date "end_date"
    t.integer "no_of_goods"
    t.index ["qr_generated_at"], name: "index_visitors_on_qr_generated_at"
    t.index ["qr_status"], name: "index_visitors_on_qr_status"
    t.index ["qr_token"], name: "index_visitors_on_qr_token", unique: true
    t.index ["qr_token_digest"], name: "index_visitors_on_qr_token_digest"
    t.index ["vhost_id"], name: "index_visitors_on_vhost_id"
    t.index ["visitor_staff_category_id"], name: "index_visitors_on_visitor_staff_category_id"
  end

  create_table "witnesses", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.string "mobile"
    t.bigint "incident_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["incident_id"], name: "index_witnesses_on_incident_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "amenity_operational_days", "amenities"
  add_foreign_key "attachments", "incidents"
  add_foreign_key "billing_configurations", "sites"
  add_foreign_key "cards", "users"
  add_foreign_key "communication_groups_users", "communication_groups"
  add_foreign_key "communication_groups_users", "users"
  add_foreign_key "cost_of_incidents", "incidents"
  add_foreign_key "forum_comments", "forums"
  add_foreign_key "forum_reports", "forums"
  add_foreign_key "forum_reports", "users", column: "reported_by_id"
  add_foreign_key "goods_items", "goods_in_outs"
  add_foreign_key "income_entries", "journal_entries"
  add_foreign_key "income_entries", "sites"
  add_foreign_key "income_entries", "units"
  add_foreign_key "income_entries", "users"
  add_foreign_key "interest_calculations", "cam_bills"
  add_foreign_key "interest_calculations", "sites"
  add_foreign_key "interest_calculations", "units"
  add_foreign_key "investigation_teams", "incidents"
  add_foreign_key "likes", "forums"
  add_foreign_key "likes", "users"
  add_foreign_key "mom_attendees", "mom_details"
  add_foreign_key "mom_tasks", "mom_details"
  add_foreign_key "parking_slots", "parking_configurations", column: "parking_configurations_id"
  add_foreign_key "permissions", "role_accesses"
  add_foreign_key "permissions", "role_modules"
  add_foreign_key "permit_sub_activities", "permit_activity_setups"
  add_foreign_key "permit_sub_activities", "permit_types"
  add_foreign_key "poll_options", "polls"
  add_foreign_key "poll_votes", "poll_options"
  add_foreign_key "poll_votes", "polls"
  add_foreign_key "prime_times", "amenity_booking_rules"
  add_foreign_key "registered_vehicle_visits", "registered_vehicles"
  add_foreign_key "role_accesses", "sites"
  add_foreign_key "room_availabilities", "rooms"
  add_foreign_key "room_bookings", "rooms"
  add_foreign_key "room_bookings", "sites"
  add_foreign_key "room_bookings", "users"
  add_foreign_key "room_pricings", "rooms"
  add_foreign_key "rooms", "sites"
  add_foreign_key "saml_temp_tokens", "users"
  add_foreign_key "saved_forums", "forums"
  add_foreign_key "saved_forums", "users"
  add_foreign_key "service_bookings", "service_pricings"
  add_foreign_key "service_bookings", "service_slots"
  add_foreign_key "service_bookings", "service_subcategories"
  add_foreign_key "service_bookings", "unit_configurations"
  add_foreign_key "service_bookings", "units"
  add_foreign_key "service_bookings", "users"
  add_foreign_key "service_categories", "sites"
  add_foreign_key "service_pricings", "service_subcategories"
  add_foreign_key "service_pricings", "unit_configurations"
  add_foreign_key "service_slots", "service_subcategories"
  add_foreign_key "service_subcategories", "service_categories"
  add_foreign_key "service_subcategories", "sites"
  add_foreign_key "shared_forums", "forums"
  add_foreign_key "shared_forums", "users", column: "receiver_id"
  add_foreign_key "shared_forums", "users", column: "sender_id"
  add_foreign_key "site_modules", "role_modules", column: "role_modules_id"
  add_foreign_key "site_modules", "sites"
  add_foreign_key "staff_units", "staffs"
  add_foreign_key "staff_units", "units"
  add_foreign_key "survey_answers", "survey_questions"
  add_foreign_key "survey_answers", "survey_responses"
  add_foreign_key "survey_question_options", "survey_questions"
  add_foreign_key "survey_questions", "surveys"
  add_foreign_key "survey_responses", "surveys"
  add_foreign_key "survey_responses", "users"
  add_foreign_key "unit_configurations", "sites"
  add_foreign_key "units", "unit_configurations"
  add_foreign_key "user_members", "users"
  add_foreign_key "user_portal_accesses", "portals"
  add_foreign_key "user_portal_accesses", "users"
  add_foreign_key "user_vendors", "users"
  add_foreign_key "vendors", "generic_sub_infos", column: "vendor_categories_id"
  add_foreign_key "vendors", "generic_sub_infos", column: "vendor_supplier_id"
  add_foreign_key "visitor_cards", "visitors"
  add_foreign_key "visitor_sub_categories", "visitor_categories"
  add_foreign_key "visitors", "generic_sub_infos", column: "visitor_staff_category_id"
  add_foreign_key "witnesses", "incidents"
end
