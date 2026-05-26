class Quotation < ApplicationRecord
  has_many :quotation_lines, foreign_key: :quotation_id, dependent: :destroy
  has_many :quotation_histories, foreign_key: :quotation_id, dependent: :destroy
  has_many :completion_certificates, foreign_key: :quotation_id, dependent: :destroy
  belongs_to :site, optional: true
  belongs_to :ticket, class_name: "Complaint", foreign_key: :ticket_id

  accepts_nested_attributes_for :quotation_lines, allow_destroy: true
  accepts_nested_attributes_for :quotation_histories, allow_destroy: true

  before_save :compute_total_amount

  private

  def compute_total_amount
    total = quotation_lines.to_a.sum { |l| (l.qty || 1).to_f * (l.rate || 0).to_f }
    after_disc = total * (1 - (discount_pct || 0).to_f / 100.0)
    self.total_amount = after_disc * (1 + (tax_pct || 0).to_f / 100.0)
  end
end
