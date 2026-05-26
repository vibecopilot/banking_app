class CreateExtensions < ActiveRecord::Migration[5.1]
  def change
    create_table :extensions do |t|
      t.integer :permit_id
      t.date :ext_date
      t.time :ext_time
      t.integer :created_by_id

      t.timestamps
    end
  end
end
