class AddColumnssToMailRoomInbound < ActiveRecord::Migration[5.1]
  def change
    add_column :mail_room_inbounds, :mark_as_collected, :boolean
    add_column :mail_room_outbounds, :mark_as_collected, :boolean
    add_column :mail_room_inbounds, :entity, :string
  end
end
