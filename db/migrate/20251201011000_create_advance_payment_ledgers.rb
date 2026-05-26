class CreateAdvancePaymentLedgers < ActiveRecord::Migration[5.1]
  def change
    create_table :advance_payment_ledgers do |t|
      t.bigint :unit_id, null: false
      t.integer :months_paid, null: false, default: 0
      t.decimal :amount, precision: 14, scale: 2, null: false, default: 0
      t.date :paid_on, null: false
      t.date :possession_date_ref
      t.string :mode
      t.string :reference_no
      t.timestamps
    end
    add_index :advance_payment_ledgers, :unit_id
  end
end
