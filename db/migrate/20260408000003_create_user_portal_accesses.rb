class CreateUserPortalAccesses < ActiveRecord::Migration[5.2]
  def change
    create_table :user_portal_accesses do |t|
      t.references :user,   null: false, foreign_key: true
      t.references :portal, null: false, foreign_key: true
      t.timestamps
    end
    add_index :user_portal_accesses, [:user_id, :portal_id], unique: true
  end
end
