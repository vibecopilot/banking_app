class CamTenantCharge < ApplicationRecord
  self.table_name = 'tenant_charges'

  enum status: { pending: 'pending', paid: 'paid' }, _prefix: :charge
  enum charge_type: { move_in: 'move_in', move_out: 'move_out' }, _prefix: true

  validates :unit_id, :charge_type, :base_amount, :gst_rate_percent, :gst_amount, :total_amount, :date, presence: true
end

