class AddMandatoryToQuestions < ActiveRecord::Migration[5.1]
  def change
    add_column :questions, :question_mandatory, :boolean, default: false
    add_column :questions, :image_mandatory, :boolean, default: false
  end
end
