class AddFixedAmountColumnToAmenity < ActiveRecord::Migration[5.1]
  def change
    add_column :amenities, :fixed_amount, :string
    add_column :amenities, :is_fixed, :boolean
  end
end
