class CreatePolls < ActiveRecord::Migration[5.1]
  def change
    create_table :polls do |t|
      t.string :title
      t.text :description
      t.date :start_date
      t.date :end_date
      t.string :visibility
      t.integer :target_groups
      t.integer :created_by_id

      t.timestamps
    end
  end
end
