class CreateTransportations < ActiveRecord::Migration[5.1]
  def change
    create_table :transportations do |t|
      t.string :on_behalf_of
      t.string :pickup_location
      t.string :dropoff_location
      t.date :date
      t.time :time
      t.integer :no_of_passengers
      t.text :additional_note
      t.string :transportation_type

      t.timestamps
    end
  end
end
