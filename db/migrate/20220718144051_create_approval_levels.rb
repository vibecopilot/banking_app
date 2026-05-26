class CreateApprovalLevels < ActiveRecord::Migration[5.1]
  def change
    create_table :approval_levels do |t|
      t.string :name
      t.integer :site_id
      t.integer :user_id
      t.integer :order

      t.timestamps
    end
  end
end
