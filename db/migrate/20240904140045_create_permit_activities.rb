class CreatePermitActivities < ActiveRecord::Migration[5.1]
  def change
    create_table :permit_activities do |t|
      t.integer :permit_id
      t.integer :activity
      t.integer :sub_activity
      t.integer :category_of_hazards
      t.string :risks

      t.timestamps
    end
  end
end
