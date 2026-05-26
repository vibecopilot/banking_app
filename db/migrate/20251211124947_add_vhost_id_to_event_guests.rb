class AddVhostIdToEventGuests < ActiveRecord::Migration[5.1]
  def change
    add_column :event_guests, :vhost_id, :integer
    add_index :event_guests, :vhost_id
  end
end
