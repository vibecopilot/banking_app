class CreateVisitorGroupInvites < ActiveRecord::Migration[5.1]
  def change
    create_table :visitor_group_invites do |t|
      t.integer :site_id
      t.integer :invited_by_id
      
      t.timestamps
    end
    
    add_index :visitor_group_invites, :site_id
    add_index :visitor_group_invites, :invited_by_id
  end
end
