class CamSetting < ApplicationRecord
  self.table_name = 'cam_settings'

  validates :rate_per_sqft, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :gst_rate_percent, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :advance_months_required, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end

