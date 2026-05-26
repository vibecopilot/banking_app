class AddCategoryIdToChecklist < ActiveRecord::Migration[5.1]
  def change
    add_column :checklists, :category_id, :integer
    add_column :checklists, :ticket_enabled, :boolean
    add_column :checklists, :ticket_assigned_to_id, :integer
  end
end
