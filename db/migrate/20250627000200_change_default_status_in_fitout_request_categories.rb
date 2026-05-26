class ChangeDefaultStatusInFitoutRequestCategories < ActiveRecord::Migration[5.1]
  def change
    change_column_default :fitout_request_categories, :status, 'pending'
  end
end
