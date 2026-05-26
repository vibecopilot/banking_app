class AddGroupIdToEvent < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :group_id, :integer
    add_column :events, :email_enabled, :boolean
    add_column :events, :rsvp_enabled, :boolean
    add_column :events, :important, :boolean
  end
end
