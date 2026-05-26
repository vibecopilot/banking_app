class AddHelptextToQuestions < ActiveRecord::Migration[5.1]
  def change
    add_column :questions, :help_text, :string
  end
end
