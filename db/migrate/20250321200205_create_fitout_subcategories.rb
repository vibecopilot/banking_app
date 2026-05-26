class CreateFitoutSubcategories < ActiveRecord::Migration[5.1]
  def change
    create_table :fitout_subcategories do |t|
      t.string :fitout_category_name
      t.integer :fitout_category_id
      t.string :name
      t.integer :position
      t.boolean :active
      t.integer :issue_type_id
      t.text :fitout_text
      t.json :bhk_prices

      t.timestamps
    end
  end
end
