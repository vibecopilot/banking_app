class RenameResourIdToResourceIdInPayments < ActiveRecord::Migration[5.1]
  def change
    rename_column :payments, :resour_id, :resource_id
  end
end
