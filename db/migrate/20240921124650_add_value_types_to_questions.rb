class AddValueTypesToQuestions < ActiveRecord::Migration[5.1]
  def change
    add_column :questions, :value_type1, :string
    add_column :questions, :value_type2, :string
    add_column :questions, :value_type3, :string
    add_column :questions, :value_type4, :string
    
  end
end
