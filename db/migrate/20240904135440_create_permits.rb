class CreatePermits < ActiveRecord::Migration[5.1]
  def change
    create_table :permits do |t|
      t.string :name
      t.string :contact_number
      t.integer :site_id
      t.integer :unit_id
      t.string :permit_for
      t.integer :building_id
      t.integer :floor_id
      t.integer :room_id
      t.string :client_specific
      t.string :entity
      t.string :copy_to_string
      t.string :permit_type
      t.integer :vendor_id
      t.datetime :issue_date_and_time
      t.datetime :expiry_date_and_time
      t.text :comment
      t.string :permit_status
      t.boolean :extention_status
      t.integer :created_by_id

      t.timestamps
    end
  end
end
