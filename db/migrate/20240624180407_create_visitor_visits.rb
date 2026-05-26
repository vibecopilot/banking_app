class CreateVisitorVisits < ActiveRecord::Migration[5.1]
  def change
    create_table :visitor_visits do |t|
      t.integer :visitor_id
      t.datetime :check_in
      t.datetime :check_out

      t.timestamps
    end
  end
end
