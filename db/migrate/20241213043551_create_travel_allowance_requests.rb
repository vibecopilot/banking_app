class CreateTravelAllowanceRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :travel_allowance_requests do |t|
      t.integer :employee_id
      t.string :employee_name
      t.string :expense_category
      t.date :date_of_expense
      t.decimal :amount_spent
      t.string :approval_status
      t.decimal :reimbursement_amount
      t.string :reimbursement_method
      t.boolean :manager_approval
      t.string :reimbursement_confirmation_email
      t.text :description_of_expense

      t.timestamps
    end
  end
end
