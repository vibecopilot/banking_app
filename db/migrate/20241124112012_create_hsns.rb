class CreateHsns < ActiveRecord::Migration[5.1]
  def change
    create_table :hsns do |t|
      t.string :type
      t.string :category
      t.string :code
      t.float :sgst_rate
      t.float :cgst_rate
      t.float :igst_rate
      t.boolean :active
      t.integer :created_by
      t.integer :updated_by
      t.integer :company_id
      t.integer :hsn_type

      t.timestamps
    end
  end
end
