class AddEndDateToBlockedDays < ActiveRecord::Migration[5.1]
  def change
    add_column :blocked_days, :end_date, :date
  end
end
