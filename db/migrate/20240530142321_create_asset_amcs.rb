class CreateAssetAmcs < ActiveRecord::Migration[5.1]
  def change
    create_table :asset_amcs do |t|
      t.integer :vendor_id
      t.integer :asset_id
      t.date :start_date
      t.date :end_date
      t.string :frequency

      t.timestamps
    end
  end
end
