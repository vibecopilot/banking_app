class AddMultilevelApprovalFields < ActiveRecord::Migration[5.2]
  def change
    add_column :approvals, :current_level, :integer, default: 0

    add_column :approval_levels, :approval_id, :integer
    add_column :approval_levels, :threshold, :decimal
    add_column :approval_levels, :decision, :string, default: "pending"
    add_column :approval_levels, :comment, :text
    add_column :approval_levels, :acted_at, :datetime
    add_index :approval_levels, :approval_id
  end
end
