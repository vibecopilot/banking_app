class CreateServicePricings < ActiveRecord::Migration[5.1]
  def change
    create_table :service_pricings do |t|
      t.decimal :price, precision: 10, scale: 2, null: false
      t.decimal :discount_percentage, precision: 5, scale: 2, default: 0
      t.decimal :tax_percentage, precision: 5, scale: 2, default: 0
      t.boolean :active, default: true
      t.references :service_subcategory, null: false, foreign_key: true
      t.references :unit_configuration, null: false, foreign_key: true

      t.timestamps
    end

    # add_index :service_pricings, [:service_subcategory_id, :unit_configuration_id], unique: true, name: 'index_service_pricings_on_subcategory_and_unit_config'
  end
end
