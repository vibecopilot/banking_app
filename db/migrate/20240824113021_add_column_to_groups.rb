class AddColumnToGroups < ActiveRecord::Migration[5.1]
  def change
    add_column :groups, :created_by_id, :integer
  end
end
