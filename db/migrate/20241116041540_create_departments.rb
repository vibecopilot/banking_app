class CreateDepartments < ActiveRecord::Migration[5.1]
  def change
    create_table :departments do |t|
      t.string :department_name
      t.integer :site_id
      t.integer :company_id
      t.boolean :active
      t.integer :created_by

      t.timestamps
    end
  end
end
