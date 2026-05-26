class CreateGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :groups do |t|
      t.string :group_name
      t.string :group_type
      t.integer :group_admin
      t.string :group_roles
      t.string :group_permissions
      t.string :group_activities
      t.integer :add_members
      t.text :group_description

      t.timestamps
    end
  end
end
