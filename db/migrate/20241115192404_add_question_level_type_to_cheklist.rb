class AddQuestionLevelTypeToCheklist < ActiveRecord::Migration[5.1]
  def change
    add_column :checklists, :ticket_level_type, :string
  end
end
