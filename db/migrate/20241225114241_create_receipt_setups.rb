class CreateReceiptSetups < ActiveRecord::Migration[5.1]
  def change
    create_table :receipt_setups do |t|
      t.string :prefix
      t.integer :next_number
      t.boolean :auto_generate
      t.string :receipt_number
      t.integer :created_by
      t.integer :site_id

      t.timestamps
    end
  end
end
