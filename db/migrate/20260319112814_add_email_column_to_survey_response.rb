class AddEmailColumnToSurveyResponse < ActiveRecord::Migration[5.2]
  def change
    add_column :survey_responses, :respond_mail, :string
  end
end
