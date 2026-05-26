class AddCheckInFieldsToEventUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :event_users, :check_in_token, :string
    add_column :event_users, :checked_in, :boolean
    add_column :event_users, :checked_in_at, :datetime
  end
end
