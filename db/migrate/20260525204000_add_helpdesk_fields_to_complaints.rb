class AddHelpdeskFieldsToComplaints < ActiveRecord::Migration[5.2]
  def change
    add_column :complaints, :ticket_type, :string
    add_column :complaints, :impact_details, :text
    add_column :complaints, :mode, :string
    add_column :complaints, :scheduled_start_time, :datetime
    add_column :complaints, :scheduled_end_time, :datetime
    add_column :complaints, :solution, :text
    add_column :complaints, :workaround, :text
    add_column :complaints, :post_incident_action, :text
    add_column :complaints, :group_name, :string
    add_column :complaints, :items, :text
    add_column :complaints, :emails_to_notify, :text
    add_column :complaints, :due_date_by, :datetime
    add_column :complaints, :response_due_date, :datetime
    add_column :complaints, :requester_phone, :string
    add_column :complaints, :requester_department, :string
    add_column :complaints, :requester_job, :string
    add_column :complaints, :responded_at, :datetime
  end
end
