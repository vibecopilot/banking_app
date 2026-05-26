class CreateAmcInvoices < ActiveRecord::Migration[5.1]
  def change
    create_table :amc_invoices do |t|
      t.integer :asset_amc_id
      t.string :invoice_number
      t.decimal :amount, precision: 10, scale: 2
      t.date :invoice_date
      t.string :document

      t.timestamps
    end
  end
end
