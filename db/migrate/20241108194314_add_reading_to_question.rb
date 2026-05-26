class AddReadingToQuestion < ActiveRecord::Migration[5.1]
  def change
    add_column :questions, :reading, :boolean
  end
end
