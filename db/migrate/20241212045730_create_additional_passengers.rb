class CreateAdditionalPassengers < ActiveRecord::Migration[5.1]
  def change
    create_table :additional_passengers do |t|
      t.string :name
      t.string :gender
      t.integer :flight_request_id

      t.timestamps
    end
  end
end
