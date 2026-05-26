class VehicleDetail < ApplicationRecord
  belongs_to :user

  validates :vehicle_type, presence: true
  validates :vehicle_no, presence: true
end
