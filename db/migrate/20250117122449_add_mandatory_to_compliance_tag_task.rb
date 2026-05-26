class AddMandatoryToComplianceTagTask < ActiveRecord::Migration[5.1]
  def change
    add_column :compliance_tag_tasks, :mandatory, :boolean
    change_column :compliance_tag_tasks, :weightage, :integer
  end
end
