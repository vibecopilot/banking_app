class CreateContactBooks < ActiveRecord::Migration[5.1]
  def change
    create_table :contact_books do |t|
      t.string :name
      t.integer :site_id
      t.integer :generic_info_id
      t.integer :mobile

      t.timestamps
    end
  end
end
