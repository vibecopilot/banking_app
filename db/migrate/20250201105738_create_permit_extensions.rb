class CreatePermitExtensions < ActiveRecord::Migration[5.1]
  def change
    create_table :permit_extensions do |t|
      t.integer :permit_id
      t.integer :site_id
      t.text :reason
      t.date :ext_date
      t.time :ext_time
      t.text :assign_to_ids

      t.timestamps
    end
  end
end
