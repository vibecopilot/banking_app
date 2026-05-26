class CreateCamCoreTables < ActiveRecord::Migration[5.1]
  def change
    create_table :cam_settings do |t|
      t.bigint :project_id
      t.decimal :rate_per_sqft, precision: 12, scale: 4, null: false, default: 0
      t.decimal :gst_rate_percent, precision: 5, scale: 2, null: false, default: 0
      t.integer :advance_months_required, null: false, default: 0
      t.timestamps
    end

    create_table :unit_cam_configs do |t|
      t.bigint :unit_id, null: false
      t.decimal :carpet_area_sqft, precision: 12, scale: 3, null: false, default: 0
      t.date :cam_start_date, null: false
      t.timestamps
    end
    add_index :unit_cam_configs, :unit_id, unique: true
    add_index :unit_cam_configs, :cam_start_date

    create_table :monthly_expenses do |t|
      t.bigint :project_id
      t.integer :year, null: false
      t.integer :month, null: false
      t.string :category, null: false
      t.decimal :amount, precision: 14, scale: 2, null: false, default: 0
      t.timestamps
    end
    add_index :monthly_expenses, [:project_id, :year, :month, :category], unique: true, name: 'idx_cam_monthly_expenses_unique'

    create_table :cam_unit_bills do |t|
      t.bigint :unit_id, null: false
      t.integer :year, null: false
      t.integer :month, null: false
      t.decimal :carpet_area_sqft, precision: 12, scale: 3, null: false
      t.decimal :daily_rate_per_sqft, precision: 12, scale: 6, null: false
      t.integer :active_days, null: false
      t.decimal :base_amount, precision: 14, scale: 2, null: false
      t.decimal :gst_rate_percent, precision: 5, scale: 2, null: false
      t.decimal :gst_amount, precision: 14, scale: 2, null: false
      t.decimal :total_amount, precision: 14, scale: 2, null: false
      t.string :status, null: false, default: 'generated'
      t.timestamps
    end
    add_index :cam_unit_bills, [:unit_id, :year, :month], unique: true, name: 'idx_cam_unit_bills_unique_period'

    create_table :advance_maintenances do |t|
      t.bigint :unit_id, null: false
      t.integer :demand_no, null: false
      t.date :due_date, null: false
      t.decimal :base_amount, precision: 14, scale: 2, null: false
      t.decimal :gst_rate_percent, precision: 5, scale: 2, null: false
      t.decimal :gst_amount, precision: 14, scale: 2, null: false
      t.decimal :total_amount, precision: 14, scale: 2, null: false
      t.string :status, null: false, default: 'pending'
      t.timestamps
    end
    add_index :advance_maintenances, [:unit_id, :demand_no], unique: true

    create_table :tenant_charges do |t|
      t.bigint :unit_id, null: false
      t.string :charge_type, null: false
      t.decimal :base_amount, precision: 14, scale: 2, null: false
      t.decimal :gst_rate_percent, precision: 5, scale: 2, null: false
      t.decimal :gst_amount, precision: 14, scale: 2, null: false
      t.decimal :total_amount, precision: 14, scale: 2, null: false
      t.date :date, null: false
      t.string :status, null: false, default: 'pending'
      t.timestamps
    end
    add_index :tenant_charges, :unit_id
    add_index :tenant_charges, :date

    create_table :receipts do |t|
      t.string :bill_type, null: false
      t.bigint :bill_id, null: false
      t.decimal :amount, precision: 14, scale: 2, null: false
      t.date :date, null: false
      t.string :reference_no
      t.timestamps
    end
    add_index :receipts, [:bill_type, :bill_id]
  end
end
