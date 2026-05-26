class AddReviewerToComplianceConfigTag < ActiveRecord::Migration[5.1]
  def change
      add_column :compliance_tracker_tags, :reviewed_by_id, :integer
      add_column :compliance_tracker_tags, :objective, :text
      add_column :compliance_tracker_tags, :reviewed_on, :datetime
  end
end
