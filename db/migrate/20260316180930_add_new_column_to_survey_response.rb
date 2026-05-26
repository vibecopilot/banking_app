class AddNewColumnToSurveyResponse < ActiveRecord::Migration[5.2]
  def change
    add_column :survey_responses, :company_name, :string
    add_column :survey_responses, :floor_unit, :string
    add_column :survey_responses, :feedback_date, :date
    add_column :survey_responses, :feedback_given_by, :string
    add_column :survey_responses, :contact_details, :string
  end
end
