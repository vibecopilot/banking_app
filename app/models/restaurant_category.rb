class RestaurantCategory < ApplicationRecord
  belongs_to :food_and_beverage

  validates :name, presence: true
end
