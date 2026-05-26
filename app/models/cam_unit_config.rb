class CamUnitConfig < ApplicationRecord
  self.table_name = 'unit_cam_configs'

  validates :unit_id, presence: true, uniqueness: true
  validates :carpet_area_sqft, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :cam_start_date, presence: true
end

