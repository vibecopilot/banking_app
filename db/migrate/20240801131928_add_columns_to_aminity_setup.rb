class AddColumnsToAminitySetup < ActiveRecord::Migration[5.1]
  def change
    add_column :aminity_setups, :break_time_start, :time
    add_column :aminity_setups, :break_time_end, :time
    add_column :aminity_setups, :terms_and_conditions, :text
  end
end
