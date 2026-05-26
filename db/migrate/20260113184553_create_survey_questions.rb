class CreateSurveyQuestions < ActiveRecord::Migration[5.1]
  def change
    create_table :survey_questions do |t|
      t.references :survey, foreign_key: true
      t.string :q_title
      t.string :question_type
      t.integer :position
      t.boolean :required
      t.integer :min_value
      t.integer :max_value

      t.timestamps
    end
  end
end
