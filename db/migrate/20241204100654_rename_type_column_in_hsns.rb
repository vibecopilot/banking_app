class RenameTypeColumnInHsns < ActiveRecord::Migration[5.1]
  def change
    remove_column :hsns, :type, :string

    # Change 'hsn_type' column's data type to string
    change_column :hsns, :hsn_type, :string
  end
end
