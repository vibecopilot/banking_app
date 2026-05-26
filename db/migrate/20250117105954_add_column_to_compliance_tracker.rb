class AddColumnToComplianceTracker < ActiveRecord::Migration[5.1]
  def change
    add_column :compliance_trackers, :due_date, :date
  end
end
