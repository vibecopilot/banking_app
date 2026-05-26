class CreateSurveys < ActiveRecord::Migration[5.1]
  def change
    create_table :surveys do |t|
      t.string :survey_title
      t.datetime :start_date
      t.datetime :end_date
      t.text :description
      t.integer :created_by_id
      t.string :status

      t.timestamps
    end
  end
end
