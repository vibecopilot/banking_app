class CreateInterestCalculations < ActiveRecord::Migration[5.1]
  def change
    create_table :interest_calculations do |t|
      t.references :site, foreign_key: true
      t.references :unit, foreign_key: true
      t.references :cam_bill, foreign_key: true
      t.decimal :principal_amount
      t.decimal :interest_rate
      t.decimal :interest_amount
      t.date :calculation_date
      t.date :from_date
      t.date :to_date
      t.integer :days_overdue
      t.string :status
      t.text :notes

      t.timestamps
    end
  end
end
