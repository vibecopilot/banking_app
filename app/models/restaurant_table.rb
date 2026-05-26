class RestaurantTable < ApplicationRecord
  belongs_to :food_and_beverage
  belongs_to :restaurant_floor, optional: true

  validates :capacity, numericality: { greater_than_or_equal_to: 0 }
end
