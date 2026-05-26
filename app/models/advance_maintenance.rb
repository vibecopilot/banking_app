class CamAdvanceMaintenance < ApplicationRecord
  self.table_name = 'advance_maintenances'

  enum status: { pending: 'pending', paid: 'paid' }

  validates :unit_id, :demand_no, :due_date, :base_amount, :gst_rate_percent, :gst_amount, :total_amount, presence: true
end
