class CreateSnagQuestOptions < ActiveRecord::Migration[5.1]
  def change
    create_table :snag_quest_options do |t|
      t.integer :question_id
      t.string :qname
      t.integer :active
      t.integer :company_id
      t.string :option_type

      t.timestamps
    end
  end
end
