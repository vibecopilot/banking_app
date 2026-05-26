class AddColumnToForums < ActiveRecord::Migration[5.1]
  def change
    add_column :forums, :created_by_id, :integer
  end
end
