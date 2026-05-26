class CreateSurveyQuestionOptions < ActiveRecord::Migration[5.1]
  def change
    create_table :survey_question_options do |t|
      t.references :survey_question, foreign_key: true
      t.string :label
      t.integer :position

      t.timestamps
    end
  end
end
