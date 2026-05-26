class AddCtypeToChecklists < ActiveRecord::Migration[5.1]
  def change
    add_column :checklists, :ctype, :string, :default => "routine"
  end
end
