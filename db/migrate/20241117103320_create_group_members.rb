class CreateGroupMembers < ActiveRecord::Migration[5.1]
  def change
    create_table :group_members do |t|
      t.integer :group_id
      t.integer :site_id
      t.integer :company_id

      t.timestamps
    end
  end
end
