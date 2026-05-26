class AddColumnsToMailRoomInbound < ActiveRecord::Migration[5.1]
  def change
    add_column :mail_room_inbounds, :receipant_name, :string
    add_column :mail_room_inbounds, :unit, :integer
    add_column :mail_room_inbounds, :department_id, :integer
    add_column :mail_room_inbounds, :status, :string
    add_column :mail_room_inbounds, :aging, :integer
    add_column :mail_room_inbounds, :collect_on, :datetime
    add_column :mail_room_inbounds, :collect_by_id, :integer
    add_column :mail_room_outbounds, :unit, :integer
  end
end
