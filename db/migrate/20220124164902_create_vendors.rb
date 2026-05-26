class CreateVendors < ActiveRecord::Migration[5.1]
  def change
    create_table :vendors do |t|
      t.string :vendor_name
      t.string :company_name
      t.string :mobile
      t.string :email
      t.integer :site_id
      t.string :vtype
      t.text :notes

      t.timestamps
    end
  end
end
