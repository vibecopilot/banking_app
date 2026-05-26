class CreateVisitorAlertConfigs < ActiveRecord::Migration[5.1]
  def change
    create_table :visitor_alert_configs do |t|
      t.integer :site_id
      t.boolean :enabled, default: false
      t.integer :threshold_value, default: 4
      t.string :threshold_unit, default: 'hours'
      t.datetime :last_alert_sent_at

      t.timestamps
    end
    
    add_index :visitor_alert_configs, :site_id, unique: true
  end
end
