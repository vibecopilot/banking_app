class CreateCamBills < ActiveRecord::Migration[5.1]
  def change
    create_table :cam_bills do |t|
      t.integer :unit_id
      t.integer :user_id
      t.date :bill_date
      t.date :due_date
      t.float :total_amount
      t.integer :created_by
      t.integer :sub_amount

      t.timestamps
    end
  end
end
