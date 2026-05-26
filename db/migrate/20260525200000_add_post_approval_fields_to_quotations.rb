class AddPostApprovalFieldsToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :visited_at, :datetime
    add_column :quotations, :visited_by, :string
    add_column :quotations, :work_started_at, :datetime
    add_column :quotations, :work_completed_at, :datetime
    add_column :quotations, :work_notes, :text
  end
end
