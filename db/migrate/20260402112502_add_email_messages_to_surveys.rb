class AddEmailMessagesToSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :surveys, :invitation_message, :text
    add_column :surveys, :thank_you_message, :text
  end
end
