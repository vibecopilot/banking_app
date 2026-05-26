class CreateSuppliers < ActiveRecord::Migration[5.2]
  def change
    create_table :suppliers do |t|
      t.string  :name
      t.string  :contact_person
      t.string  :email
      t.string  :phone
      t.text    :address
      t.boolean :status, default: true
      t.integer :site_id
      t.integer :created_by_id
      t.timestamps
    end
    add_index :suppliers, :site_id
    add_index :suppliers, :status
  end
end
