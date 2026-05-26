class AddStatusToCmplianceTrackerTag < ActiveRecord::Migration[5.1]
  def change
    add_column :compliance_tracker_tags, :status, :string
  end
end
