class CreateSnagQuestions < ActiveRecord::Migration[5.1]
  def change
    create_table :snag_questions do |t|
      t.string :qtype
      t.text :descr
      t.integer :checklist_id
      t.integer :user_id
      t.boolean :img_mandatory
      t.boolean :quest_mandatory
      t.integer :active
      t.integer :company_id
      t.integer :qnumber

      t.timestamps
    end
  end
end
