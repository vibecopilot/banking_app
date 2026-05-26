class CreateTickets < ActiveRecord::Migration[5.1]
  def change
    create_table :tickets do |t|
      t.integer :site_id
      t.integer :category_id
      t.integer :sub_category_id
      t.string :status
      t.text :description
      t.integer :created_by_id
      t.integer :assigned_to_id
      t.float :total_cost
      t.integer :tm_id

      t.timestamps
    end
  end
end
