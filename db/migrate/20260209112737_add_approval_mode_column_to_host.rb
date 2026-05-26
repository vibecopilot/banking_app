class AddApprovalModeColumnToHost < ActiveRecord::Migration[5.1]
  def change
    add_column :hosts, :approval_mode, :string
  end
end
