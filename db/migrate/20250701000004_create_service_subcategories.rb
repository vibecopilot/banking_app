class CreateServiceSubcategories < ActiveRecord::Migration[5.1]
  def change
    create_table :service_subcategories do |t|
      t.string :name, null: false
      t.string :description
      t.text :terms_and_conditions
      t.integer :duration_minutes # estimated service duration
      t.integer :advance_booking_hours, default: 24 # minimum hours to book in advance
      t.integer :cancellation_hours, default: 4 # hours before which cancellation is allowed
      t.integer :sort_order, default: 0
      t.boolean :active, default: true
      t.references :service_category, null: false, foreign_key: true
      t.references :site, null: false, foreign_key: true

      t.timestamps
    end

    # add_index :service_subcategories, [:service_category_id, :name], unique: true
    # add_index :service_subcategories, [:site_id, :active]
  end
end
