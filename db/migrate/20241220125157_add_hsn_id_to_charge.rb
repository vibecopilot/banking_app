class AddHsnIdToCharge < ActiveRecord::Migration[5.1]
  def change
    add_column :charges, :hsn_id, :integer
  end
end
