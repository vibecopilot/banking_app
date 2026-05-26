class RenameTypeColumnInMailRoomOutbounds < ActiveRecord::Migration[5.1]
  def change
    rename_column :mail_room_outbounds, :type, :mail_outbound_type
  end
end
