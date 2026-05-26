class CreateHosts < ActiveRecord::Migration[5.1]
  def change
    create_table :hosts do |t|
      t.integer :visitor_id
      t.integer :user_id

      t.timestamps
    end
  end
end
