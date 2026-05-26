class AddSnagChecklistIdToSnagQuestions < ActiveRecord::Migration[5.1]
  def change
    add_reference :snag_questions, :snag_checklist, foreign_key: true
  end
end
