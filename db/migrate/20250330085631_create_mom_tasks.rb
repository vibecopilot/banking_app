class CreateMomTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :mom_tasks do |t|
      t.references :mom_detail, foreign_key: true
      t.text :description
      t.integer :responsible_person_id
      t.date :target_date
      t.string :responsible_person_email
      t.string :responsible_person_type
      t.string :responsible_person_name
      t.integer :company_tag_id

      t.timestamps
    end
  end
end
