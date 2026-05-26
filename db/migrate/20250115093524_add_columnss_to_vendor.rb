class AddColumnssToVendor < ActiveRecord::Migration[5.1]
  def change
    add_column :vendors, :status, :string
    add_column :mail_room_outbounds, :entity, :string
    add_column :mail_room_outbounds, :collect_by_id, :integer
    add_column :mail_room_outbounds, :status, :string
    change_column :mail_room_outbounds, :awb_number, :string
    change_column :mail_room_inbounds, :awb_number, :string
  end
end
