class AddWorkingScheduleToStaff < ActiveRecord::Migration[5.1]
  def change
    add_column :staffs, :working_schedule, :json
  end
end
