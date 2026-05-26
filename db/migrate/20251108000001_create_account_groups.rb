class CreateAccountGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :account_groups do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.string :group_type, null: false
      t.integer :parent_id
      t.integer :site_id
      t.text :description
      t.boolean :active, default: true
      t.boolean :is_system, default: false

      t.timestamps
    end

    add_index :account_groups, :site_id
    add_index :account_groups, :parent_id
    add_index :account_groups, [:code, :site_id], unique: true
    add_index :account_groups, :group_type
  end
end
