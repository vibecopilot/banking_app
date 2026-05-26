class CreateFieldSenseMeetingManagements < ActiveRecord::Migration[5.1]
  def change
    create_table :field_sense_meeting_managements do |t|
      t.string :meeting_title
      t.datetime :meeting_date_and_time
      t.integer :participants
      t.string :location
      t.string :travel_mode
      t.string :expenses
      t.text :meeting_agenda
      t.integer :created_by_id

      t.timestamps
    end
  end
end
