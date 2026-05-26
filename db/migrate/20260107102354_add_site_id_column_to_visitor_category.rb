class AddSiteIdColumnToVisitorCategory < ActiveRecord::Migration[5.1]
  def change
    add_column :visitor_categories, :site_id, :integer
  end
end
