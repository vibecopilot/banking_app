class ChangeCreatedByIdDataTypeInVisitors < ActiveRecord::Migration[5.1]
  def change
        change_column :visitors, :created_by_id, :integer
  end
end
