class CreateVisitorCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :visitor_categories do |t|
      t.string :name
      t.string :code
      t.boolean :active , default: true

      t.timestamps
    end
  end
end
