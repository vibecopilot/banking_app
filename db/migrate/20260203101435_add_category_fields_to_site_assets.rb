class AddCategoryFieldsToSiteAssets < ActiveRecord::Migration[5.1]
  def change
    add_column :site_assets, :category, :string, default: 'general'
    add_column :site_assets, :category_data, :json, null: true
    add_column :site_assets, :custom_sections, :json, null: true
    
    add_index :site_assets, :category
  end
end