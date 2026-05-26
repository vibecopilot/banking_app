class CreateMomDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :mom_details do |t|
      t.text :title
      t.datetime :meeting_date
      t.integer :created_by_id
      t.boolean :active
      t.string :company_tag_name

      t.timestamps
    end
  end
end
