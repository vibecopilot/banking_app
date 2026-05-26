class ChangeUnitIdToTextInSoftServices < ActiveRecord::Migration[5.1]
  def change
    change_column :soft_services, :unit_id, :text
  end
end
