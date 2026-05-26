class CreateCronSettings < ActiveRecord::Migration[5.1]
  def change
    create_table :cron_settings do |t|
      t.references :cronnable, polymorphic: true, null: false
      t.string :recurrence_type
      t.integer :year_interval
      t.integer :month
      t.integer :date
      t.integer :day_of_week
      t.integer :hour
      t.integer :minute
      t.string :cron_expression

      t.timestamps
    end
  end
end
