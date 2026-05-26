class CreateOtherProjects < ActiveRecord::Migration[5.1]
  def change
    create_table :other_projects do |t|
      t.string :title
      t.text :description
      t.string :address
      t.integer :company_id

      t.timestamps
    end
  end
end
