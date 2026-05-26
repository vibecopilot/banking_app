class CamUnitBill < ApplicationRecord
  self.table_name = 'cam_unit_bills'

  belongs_to :site, optional: true

  enum status: { generated: 'generated', invoiced: 'invoiced', paid: 'paid', void: 'void' }, _prefix: :bill

  validates :unit_id, :year, :month, :carpet_area_sqft, :daily_rate_per_sqft, :active_days, :base_amount, :gst_rate_percent, :gst_amount, :total_amount, presence: true
  validates :month, inclusion: { in: 1..12 }
end

