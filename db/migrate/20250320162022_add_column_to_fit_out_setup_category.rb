class AddColumnToFitOutSetupCategory < ActiveRecord::Migration[5.1]
  def change
    add_column :fit_out_setup_categories, :assigned_id, :integer
  end
end
