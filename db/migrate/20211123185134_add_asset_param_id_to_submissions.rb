class AddAssetParamIdToSubmissions < ActiveRecord::Migration[5.1]
  def change
    add_column :submissions, :asset_param_id, :integer
  end
end
