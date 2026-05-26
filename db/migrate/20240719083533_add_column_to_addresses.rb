class AddColumnToAddresses < ActiveRecord::Migration[5.1]
  def change
    add_column :addresses, :address, :text
  end
end
