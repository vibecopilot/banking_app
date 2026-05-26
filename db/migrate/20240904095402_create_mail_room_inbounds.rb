class CreateMailRoomInbounds < ActiveRecord::Migration[5.1]
  def change
    create_table :mail_room_inbounds do |t|
      t.integer :vendor_id
      t.date :receiving_date
      t.string :sender
      t.string :mobile_number
      t.integer :awb_number
      t.string :company
      t.text :company_address_1
      t.text :company_address_2
      t.string :state
      t.string :city
      t.integer :pincode
      t.string :type
      t.integer :created_by_id

      t.timestamps
    end
  end
end
