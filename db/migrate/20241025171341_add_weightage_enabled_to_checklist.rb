class AddWeightageEnabledToChecklist < ActiveRecord::Migration[5.1]
  def change
    add_column :checklists, :weightage_enabled, :boolean
  end
end
