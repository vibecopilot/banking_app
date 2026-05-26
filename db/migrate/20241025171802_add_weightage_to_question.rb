class AddWeightageToQuestion < ActiveRecord::Migration[5.1]
  def change
    add_column :questions, :weightage, :string
  end
end
