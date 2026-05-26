class CreatePayments < ActiveRecord::Migration[5.1]
  def change
    create_table :payments do |t|
      t.integer :resour_id
      t.string :resource_type
      t.float :total_amount
      t.float :paid_amount
      t.integer :user_id
      t.string :payment_method
      t.string :transaction_id
      t.date :paymen_date

      t.timestamps
    end
  end
end
