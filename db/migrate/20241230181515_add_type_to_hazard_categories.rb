class AddTypeToHazardCategories < ActiveRecord::Migration[5.1]
  def change
    add_column :hazard_categories, :type, :string
  end
end
