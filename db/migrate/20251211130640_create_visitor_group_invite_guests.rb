class CreateVisitorGroupInviteGuests < ActiveRecord::Migration[5.1]
  def change
    create_table :visitor_group_invite_guests do |t|
      t.integer :visitor_group_invite_id
      t.string :mobile_number
      t.string :invitation_token
      t.integer :vhost_id
      t.integer :visitor_id
      t.string :name
      t.string :email
      t.integer :status
      
      t.timestamps
    end
    
    add_index :visitor_group_invite_guests, :visitor_group_invite_id, name: 'index_vg_invite_guests_on_vg_invite_id'
    add_index :visitor_group_invite_guests, :invitation_token, unique: true
    add_index :visitor_group_invite_guests, :vhost_id
    add_index :visitor_group_invite_guests, :visitor_id
  end
end
