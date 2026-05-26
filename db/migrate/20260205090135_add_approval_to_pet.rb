class AddApprovalToPet < ActiveRecord::Migration[5.1]
  def change
    add_column :pets, :is_approved, :string
    add_column :pets, :approved_at, :datetime
    add_column :pets, :rejection_reason, :string
    add_column :pets, :approved_by_id, :integer

    add_index :pets, :is_approved
    add_index :pets, :approved_by_id
  end
end
