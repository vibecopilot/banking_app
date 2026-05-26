class CreateQrVerifications < ActiveRecord::Migration[5.1]
  def change
    create_table :qr_verifications do |t|
      t.string :code, null: false
      t.datetime :expected_time, null: false
      t.datetime :valid_till, null: false
      t.integer :generated_by_id, null: false
      t.boolean :checked_in, default: false, null: false
      t.datetime :checked_in_at
      t.integer :checked_in_by_id
      t.integer :site_id, null: false
      t.integer :qr_image_id
      t.string :purpose
      t.text :notes

      t.timestamps
    end
    add_index :qr_verifications, :code, unique: true
    add_index :qr_verifications, :generated_by_id
    add_index :qr_verifications, :site_id
    add_index :qr_verifications, :expected_time
    add_index :qr_verifications, :checked_in
    add_index :qr_verifications, :qr_image_id
  end
end
