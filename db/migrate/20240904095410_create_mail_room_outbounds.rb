class CreateMailRoomOutbounds < ActiveRecord::Migration[5.1]
  def change
    create_table :mail_room_outbounds do |t|
      t.integer :vendor_id
      t.date :sending_date
      t.integer :sender_id
      t.string :recipient_name
      t.string :mobile_number
      t.integer :awb_number
      t.string :recipient_email_id
      t.text :recipient_address_1
      t.text :recipient_address_2
      t.string :state
      t.string :city
      t.integer :pincode
      t.string :type
      t.integer :created_by_id

      t.timestamps
    end
  end
end
