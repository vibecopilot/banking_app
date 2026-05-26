class CreateSubGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :sub_groups do |t|
      t.integer :group_id
      t.string :name

      t.timestamps
    end
  end
end
