class AddEnableColumnToEvent < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :enabled, :boolean, default: true
  end
end
