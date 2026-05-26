class SetDefaultIsActiveToTrue < ActiveRecord::Migration[5.1]
  def change
        change_column_default :users, :lad_long_required, from: nil, to: true
  end
end
