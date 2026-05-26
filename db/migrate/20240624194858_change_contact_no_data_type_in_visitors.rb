class ChangeContactNoDataTypeInVisitors < ActiveRecord::Migration[5.1]
  def change
    change_column :visitors, :contact_no, :string
  end
end
