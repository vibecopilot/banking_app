class RestaurantMenu < ApplicationRecord
  belongs_to :food_and_beverage, foreign_key: :restaurant_id, optional: true
  belongs_to :category, -> { where(info_type: "RestaurantCategory") }, foreign_key: :category_id, class_name: "GenericInfo", optional: true
  belongs_to :sub_category, foreign_key: "sub_category_id", class_name: "GenericSubInfo", optional: true
  has_one :menu_image, -> { where(relation: "MenuImage") }, foreign_key: :relation_id, class_name: "Attachfile", dependent: :destroy
end
