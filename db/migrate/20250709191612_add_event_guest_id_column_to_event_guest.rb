class AddEventGuestIdColumnToEventGuest < ActiveRecord::Migration[5.1]
  def change
    add_column :event_guests, :event_guest_id, :integer
  end
end
