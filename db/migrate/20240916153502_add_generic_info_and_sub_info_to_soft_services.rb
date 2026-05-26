class AddGenericInfoAndSubInfoToSoftServices < ActiveRecord::Migration[5.1]
  def change
    add_column :soft_services, :generic_info_id, :integer
    add_column :soft_services, :generic_sub_info_id, :integer
  end
end
