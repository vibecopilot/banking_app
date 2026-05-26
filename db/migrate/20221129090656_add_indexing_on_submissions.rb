class AddIndexingOnSubmissions < ActiveRecord::Migration[5.1]
  def change
    add_index :submissions, [:activity_id, :asset_param_id]
  end
end
