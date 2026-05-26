class TableBooking < ApplicationRecord
  belongs_to :created_by, class_name: "User", foreign_key: :created_by_id, optional: true
  belongs_to :food_and_beverage, class_name: "FoodAndBeverage", foreign_key: :restaurant_id, optional: true
  belongs_to :restaurant_table, optional: true

  validates :ondate, presence: true
  validates :ontime, presence: true
  validates :no_of_person, numericality: { greater_than: 0 }, allow_nil: true

  scope :for_date, ->(date) { where(ondate: date) }
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :upcoming, -> { where("ondate >= ?", Date.today).order(ondate: :asc, ontime: :asc) }
  scope :today, -> { where(ondate: Date.today) }
end
