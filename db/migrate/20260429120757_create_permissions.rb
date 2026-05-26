class CreatePermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :permissions do |t|
      t.references :role_accesses, foreign_key: true
      t.references :role_modules, foreign_key: true
      t.boolean :can_create
      t.boolean :can_view
      t.boolean :can_update
      t.boolean :can_delete

      t.timestamps
    end
  end
end
