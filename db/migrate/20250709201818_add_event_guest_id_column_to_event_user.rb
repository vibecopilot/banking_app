class AddEventGuestIdColumnToEventUser < ActiveRecord::Migration[5.1]
  def change
    add_column :event_users, :event_guest_id, :integer
  end
end
