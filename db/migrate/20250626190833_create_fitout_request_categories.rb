class CreateFitoutRequestCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :fitout_request_categories do |t|
      t.integer :fitout_request_id
      t.integer :category_type_id
      t.integer :attachfile_id

      t.timestamps
    end
  end
end
