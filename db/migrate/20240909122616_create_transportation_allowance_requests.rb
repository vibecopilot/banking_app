class CreateTransportationAllowanceRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :transportation_allowance_requests do |t|
      t.string :employee_name
      t.integer :employee_id
      t.string :expense_category
      t.date :date_of_expense
      t.text :description_of_expense
      t.float :amount_spent
      t.string :approval_status
      t.float :reimbursement_amount
      t.string :reimbursement_method
      t.boolean :manager_approval
      t.string :reimbursement_confirmation_email

      t.timestamps
    end
  end
end
