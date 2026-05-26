class RenameTypeColumnInMailRoomInboundsToMailType < ActiveRecord::Migration[5.1]
  def change
    rename_column :mail_room_inbounds, :type, :mail_inbound_type
  end
end
