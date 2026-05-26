class AddInvitationFieldsToEventGuests < ActiveRecord::Migration[5.1]
  def change
    add_column :event_guests, :mobile_number, :string
    add_column :event_guests, :invitation_token, :string
    add_column :event_guests, :visitor_id, :integer
    add_column :event_guests, :status, :integer, default: 0
    
    add_index :event_guests, :invitation_token, unique: true
    add_index :event_guests, :visitor_id
  end
end
