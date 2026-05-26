class AddStatusColumnToApproval < ActiveRecord::Migration[5.1]
  def change
    add_column :approvals, :status, :string
  end
end
