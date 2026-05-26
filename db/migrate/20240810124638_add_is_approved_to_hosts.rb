class AddIsApprovedToHosts < ActiveRecord::Migration[5.1]
  def change
    add_column :hosts, :is_approved, :boolean
  end
end
