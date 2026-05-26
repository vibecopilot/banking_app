class AddVisitorStaffCategoryToVisitors < ActiveRecord::Migration[5.1]
  def change
    add_reference :visitors, :visitor_staff_category, foreign_key: { to_table: :generic_sub_infos }
  end
end
