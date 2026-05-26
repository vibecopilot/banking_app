class AddOtpColumnToEventGuest < ActiveRecord::Migration[5.1]
  def change
    add_column :event_guests, :user_id, :integer
    add_column :event_guests, :otp, :string
  end
end
