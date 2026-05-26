class CreateSnagAnswers < ActiveRecord::Migration[5.1]
  def change
    create_table :snag_answers do |t|
      t.integer :question_id
      t.integer :quest_option_id
      t.string :ans_descr
      t.text :comments
      t.integer :user_id
      t.integer :company_id
      t.integer :checklist_id
      t.string :answer_type
      t.string :answer_mode

      t.timestamps
    end
  end
end
