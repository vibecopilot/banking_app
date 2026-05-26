class CreateOrganizations < ActiveRecord::Migration[5.1]
  def change
    create_table :organizations do |t|
      t.string :name
      t.integer :created_by_id

      t.timestamps
    end
  end
end
