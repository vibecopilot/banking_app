class AddAdvanceAmountToUnitCamConfigs < ActiveRecord::Migration[5.1]
  def change
    add_column :unit_cam_configs, :advance_amount, :decimal, precision: 12, scale: 2, default: 0, null: false
  end
end
