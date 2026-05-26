class FixPermissionForeignKeys < ActiveRecord::Migration[5.2]
  def change
    rename_column :permissions, :role_accesses_id, :role_access_id
    rename_column :permissions, :role_modules_id, :role_module_id
  end
end
