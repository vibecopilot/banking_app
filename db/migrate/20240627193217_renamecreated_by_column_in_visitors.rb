class RenamecreatedByColumnInVisitors < ActiveRecord::Migration[5.1]
  def change
    rename_column :visitors, :created_by, :created_by_id
  end
end
