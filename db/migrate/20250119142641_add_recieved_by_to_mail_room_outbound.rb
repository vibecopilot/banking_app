class AddRecievedByToMailRoomOutbound < ActiveRecord::Migration[5.1]
  def change
    add_column :mail_room_outbounds, :recieved_by_id, :integer
    add_column :mail_room_outbounds, :company, :string
    add_column :mail_room_outbounds, :company_address_1, :text
    add_column :mail_room_outbounds, :company_address_2, :text
  end
end
