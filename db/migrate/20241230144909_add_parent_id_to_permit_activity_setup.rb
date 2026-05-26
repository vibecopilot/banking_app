class AddParentIdToPermitActivitySetup < ActiveRecord::Migration[5.1]
  def change
    add_column :permit_activity_setups, :parent_id, :integer
  end
end
