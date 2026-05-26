class AddSupervisiorIdToChecklist < ActiveRecord::Migration[5.1]
  def change
    add_column :checklists, :supplier_id, :integer
    add_column :checklists, :supervisior_id, :integer
  end
end
