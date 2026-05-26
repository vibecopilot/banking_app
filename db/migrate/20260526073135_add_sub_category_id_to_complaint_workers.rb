class AddSubCategoryIdToComplaintWorkers < ActiveRecord::Migration[5.2]
  def change
    add_column :complaint_workers, :sub_category_id, :integer
    add_index :complaint_workers, :sub_category_id
  end
end
