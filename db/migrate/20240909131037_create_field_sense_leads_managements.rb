class CreateFieldSenseLeadsManagements < ActiveRecord::Migration[5.1]
  def change
    create_table :field_sense_leads_managements do |t|
      t.string :lead_name
      t.string :lead_source
      t.string :contact_phone
      t.string :contact_email
      t.string :company_name
      t.string :lead_status
      t.string :assigned_sales_representative
      t.date :last_contact_date
      t.date :next_follow_up_date
      t.integer :created_by_id

      t.timestamps
    end
  end
end
