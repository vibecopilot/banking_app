class CreateIssueTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :issue_types do |t|
      t.integer :society_id
      t.string :name
      t.boolean :active
    end
  end
end
