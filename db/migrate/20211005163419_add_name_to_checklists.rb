class AddNameToChecklists < ActiveRecord::Migration[5.1]
  def change
    add_column :checklists, :name, :string
  end
end
