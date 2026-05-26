class AddPriorityLevelToChecklists < ActiveRecord::Migration[5.1]
  def change
    add_column :checklists, :priority_level, :string
  end
end
