class AddStatusAndUpdatedByIdToFitoutRequestCategories < ActiveRecord::Migration[5.1]
  def change
    add_column :fitout_request_categories, :status, :string
    add_column :fitout_request_categories, :updated_by_id, :integer
  end
end
