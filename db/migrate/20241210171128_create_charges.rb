class CreateCharges < ActiveRecord::Migration[5.1]
  def change
    create_table :charges do |t|
      t.integer :site_id
      t.string :name
      t.string :code
      t.float :cgst
      t.float :sgst
      t.float :igst

      t.timestamps
    end
  end
end
