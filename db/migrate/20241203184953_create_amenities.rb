class CreateAmenities < ActiveRecord::Migration[5.1]
  def change
    create_table :amenities do |t|
      t.integer :site_id
      t.string :fac_type
      t.string :fac_name
      t.integer :member_charges
      t.integer :book_before
      t.text :disclaimer
      t.text :cancellation_policy
      t.integer :cutoff_min
      t.integer :return_percentage
      t.integer :create_by
      t.integer :active
      t.integer :member_price_adult
      t.integer :member_price_child
      t.integer :guest_price_adult
      t.integer :guest_price_child
      t.integer :min_people
      t.integer :max_people
      t.integer :cancel_before
      t.text :terms
      t.integer :advance_min
      t.integer :deposit
      t.text :description
      t.integer :max_slots

      t.timestamps
    end
  end
end
