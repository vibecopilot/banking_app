class RenameActiveToIsActiveInFitoutStatuses < ActiveRecord::Migration[5.1]
  def change
    rename_column :fitout_statuses, :active, :is_active
  end
end
