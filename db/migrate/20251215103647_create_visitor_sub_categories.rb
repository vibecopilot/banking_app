class CreateVisitorSubCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :visitor_sub_categories do |t|
      t.references :visitor_category, foreign_key: true
      t.string :name
      t.boolean :active

      t.timestamps
    end
  end
end
