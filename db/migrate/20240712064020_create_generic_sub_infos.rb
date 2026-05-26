class CreateGenericSubInfos < ActiveRecord::Migration[5.1]
  def change
    create_table :generic_sub_infos do |t|
      t.integer :generic_info_id
      t.string :name

      t.timestamps
    end
  end
end
