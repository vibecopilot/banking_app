class AddOccuresToChecklists < ActiveRecord::Migration[5.1]
  def change
    add_column :checklists, :occurs, :string
  end
end
