class RestaurantOrderItem < ApplicationRecord
	belongs_to :restaurant_order , class_name:"RestaurantOrder", foreign_key: :order_id
	belongs_to :restaurant_menu, class_name: "RestaurantMenu", foreign_key: :restaurant_menu_id, optional: true
	validates :quantity, presence:true, numericality:{greater_than: 0}
	validates :rate, presence:true
end
