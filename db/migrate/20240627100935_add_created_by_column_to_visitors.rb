class AddCreatedByColumnToVisitors < ActiveRecord::Migration[5.1]
  def change
    add_column :visitors, :created_by, :integer
  end
end
