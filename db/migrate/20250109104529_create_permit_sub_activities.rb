class CreatePermitSubActivities < ActiveRecord::Migration[5.1]
  def change
    create_table :permit_sub_activities do |t|
      t.string :name
      t.references :permit_type, foreign_key: true
      t.references :permit_activity_setup, foreign_key: true

      t.timestamps
    end
  end
end
