class ChangeCronSettingsColumnsToString < ActiveRecord::Migration[5.1]
  def change
    change_column :cron_settings, :month, :string
    change_column :cron_settings, :date, :string
    change_column :cron_settings, :day_of_week, :string
    change_column :cron_settings, :hour, :string
    change_column :cron_settings, :minute, :string
  end
end
