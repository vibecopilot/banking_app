class RestaurantFloor < ApplicationRecord
  belongs_to :food_and_beverage
  has_many :restaurant_tables, dependent: :destroy

  validates :name, presence: true
end
