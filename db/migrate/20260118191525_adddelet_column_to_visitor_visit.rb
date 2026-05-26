class AdddeletColumnToVisitorVisit < ActiveRecord::Migration[5.1]
  def change
    add_column :visitor_visits, :is_deleted, :boolean, default: false
  end
end
