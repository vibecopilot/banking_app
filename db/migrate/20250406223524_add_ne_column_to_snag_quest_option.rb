class AddNeColumnToSnagQuestOption < ActiveRecord::Migration[5.1]
  def change
    add_column :snag_quest_options, :snag_question_id, :integer
  end
end
