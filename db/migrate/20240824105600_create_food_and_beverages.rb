class CreateFoodAndBeverages < ActiveRecord::Migration[5.1]
  def change
    create_table :food_and_beverages do |t|
      t.string :restaurant_name
      t.float :cost_for_two
      t.string :mobile_number
      t.string :alternate_mobile_number
      t.string :landline_number
      t.integer :delivery_time
      t.string :cuisines
      t.string :serves_alcohols
      t.string :wheelchair_accessible
      t.string :cash_on_delivery
      t.string :pure_veg
      t.text :address
      t.text :terms_and_conditions
      t.text :disclaimer
      t.text :closing_message
      t.integer :minimum_person
      t.integer :maximum_person
      t.integer :cancel_before
      t.float :gst
      t.float :delivery_charges
      t.integer :minimum_order
      t.boolean :status
      t.integer :created_by_id

      t.timestamps
    end
  end
end
