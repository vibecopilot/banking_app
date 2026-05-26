class CreateCompanies < ActiveRecord::Migration[5.1]
  def change
    create_table :companies do |t|
      t.string :name
      t.attachment :logo
      t.integer :created_by

      t.timestamps
    end
  end
end
