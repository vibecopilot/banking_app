class ChangeSupervisiorIdTypeInChecklist < ActiveRecord::Migration[5.1]
  def change
    change_column :checklists, :supervisior_id, :text
  end
end
