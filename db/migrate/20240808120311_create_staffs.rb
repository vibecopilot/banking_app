class CreateStaffs < ActiveRecord::Migration[5.1]
  def change
    create_table :staffs do |t|
      t.string :firstname
      t.string :lastname
      t.string :email
      t.string :mobile_no
      t.integer :unit_id
      t.string :work_type
      t.integer :vendor_id
      t.datetime :valid_from
      t.datetime :valid_till
      t.boolean :status

      t.timestamps
    end
  end
end
