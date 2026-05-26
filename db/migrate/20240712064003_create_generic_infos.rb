class CreateGenericInfos < ActiveRecord::Migration[5.1]
  def change
    create_table :generic_infos do |t|
      t.string :name
      t.integer :company_id
      t.integer :site_id
      t.string :info_type

      t.timestamps
    end
  end
end
