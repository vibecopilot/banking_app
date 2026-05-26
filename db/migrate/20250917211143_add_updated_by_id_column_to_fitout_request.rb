class AddUpdatedByIdColumnToFitoutRequest < ActiveRecord::Migration[5.1]
  def change
    add_column :fitout_requests, :status_updated_by, :integer
  end
end
