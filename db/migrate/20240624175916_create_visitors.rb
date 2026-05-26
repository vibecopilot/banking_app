class CreateVisitors < ActiveRecord::Migration[5.1]
  def change
    create_table :visitors do |t|
      t.string :name
      t.integer :contact_no
      t.text :purpose
      t.integer :site_id
      t.integer :otp
      t.boolean :status
      t.datetime :start_pass
      t.datetime :end_pass

      t.timestamps
    end
  end
end
