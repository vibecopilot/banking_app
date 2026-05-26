class UpdateCronSettingColumnsToText < ActiveRecord::Migration[5.1]
  def change
    change_column :cron_settings, :month, :text
    change_column :cron_settings, :date, :text
    change_column :cron_settings, :day_of_week, :text
    change_column :cron_settings, :hour, :text
    change_column :cron_settings, :minute, :text
  end
end
