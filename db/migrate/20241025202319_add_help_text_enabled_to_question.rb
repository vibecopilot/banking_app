class AddHelpTextEnabledToQuestion < ActiveRecord::Migration[5.1]
  def change
    add_column :questions, :help_text_enbled, :boolean
    add_column :questions, :rating, :boolean
  end
end
