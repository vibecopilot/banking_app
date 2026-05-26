class CreateInvoiceSetups < ActiveRecord::Migration[5.1]
  def change
    create_table :invoice_setups do |t|
      t.string :prefix
      t.integer :next_number
      t.boolean :auto_generate
      t.integer :site_id
      t.integer :created_by

      t.timestamps
    end
  end
end
