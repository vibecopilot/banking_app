class ChangePrimeTimesToString < ActiveRecord::Migration[5.2]
  def change
    change_column :prime_times, :start_time, :string
    change_column :prime_times, :end_time, :string
  end
end
