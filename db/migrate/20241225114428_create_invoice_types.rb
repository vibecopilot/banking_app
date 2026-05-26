class CreateInvoiceTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :invoice_types do |t|
      t.string :name
      t.integer :created_by_id
      t.integer :site_id

      t.timestamps
    end
  end
end
