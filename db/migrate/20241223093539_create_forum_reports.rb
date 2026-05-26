class CreateForumReports < ActiveRecord::Migration[5.1]
  def change
    create_table :forum_reports do |t|
      t.references :forum, null: false, foreign_key: true
      t.references :reported_by, null: false, foreign_key: { to_table: :users }
      t.text :reason, null: false

      t.timestamps
    end
  end
end
