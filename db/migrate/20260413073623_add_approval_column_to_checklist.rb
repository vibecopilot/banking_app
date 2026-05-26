class AddApprovalColumnToChecklist < ActiveRecord::Migration[5.2]
  def change
    add_column :checklists, :is_approved, :boolean
    add_column :checklists, :group_id, :integer
    add_column :checklists, :sub_group_id, :integer
  end
end
