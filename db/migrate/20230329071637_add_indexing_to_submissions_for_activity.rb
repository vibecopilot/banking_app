class AddIndexingToSubmissionsForActivity < ActiveRecord::Migration[5.1]
  def change
    add_index :submissions, :activity_id
    add_index :submissions, :asset_param_id
  end
end
