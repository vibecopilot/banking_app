class AddLockOverdueToChecklist < ActiveRecord::Migration[5.1]
  def change
    add_column :checklists, :lock_overdue, :boolean
  end
end
