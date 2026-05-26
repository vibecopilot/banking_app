class RenameTypeAssetParams < ActiveRecord::Migration[5.1]
  def change
    rename_column :asset_params, :type, :param_type
  end
end
