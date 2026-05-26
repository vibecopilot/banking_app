class TaxRate < ApplicationRecord
  # Associations
  belongs_to :site, optional: true
  belongs_to :ledger, optional: true
  has_many :accounting_invoice_items, dependent: :nullify

  # Validations
  validates :name, presence: true
  validates :tax_type, presence: true
  validates :rate, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :for_site, ->(site_id) { where(site_id: [site_id, nil]) }
  scope :current, -> { where('effective_from <= ? AND (effective_to IS NULL OR effective_to >= ?)', Date.current, Date.current) }
  scope :by_type, ->(type) { where(tax_type: type) }

  # Instance methods
  def calculate_tax(amount)
    (amount * rate / 100).round(2)
  end

  def effective?
    return true if effective_from.blank? && effective_to.blank?
    return Date.current >= effective_from if effective_to.blank?
    return Date.current <= effective_to if effective_from.blank?
    Date.current.between?(effective_from, effective_to)
  end

  def display_name
    "#{name} (#{rate}%)"
  end

  # Class methods
  def self.seed_default_tax_rates(site_id)
    gst_ledger = Ledger.find_by(code: 'L-GST-OUT', site_id: site_id)
    
    tax_rates = [
      { name: 'GST 5%', tax_type: 'GST', rate: 5.0, ledger: gst_ledger },
      { name: 'GST 12%', tax_type: 'GST', rate: 12.0, ledger: gst_ledger },
      { name: 'GST 18%', tax_type: 'GST', rate: 18.0, ledger: gst_ledger },
      { name: 'GST 28%', tax_type: 'GST', rate: 28.0, ledger: gst_ledger },
      { name: 'CGST 9%', tax_type: 'CGST', rate: 9.0, ledger: gst_ledger },
      { name: 'SGST 9%', tax_type: 'SGST', rate: 9.0, ledger: gst_ledger },
    ]
    
    tax_rates.each do |tax_data|
      TaxRate.find_or_create_by(
        name: tax_data[:name],
        site_id: site_id
      ) do |t|
        t.tax_type = tax_data[:tax_type]
        t.rate = tax_data[:rate]
        t.ledger = tax_data[:ledger]
        t.active = true
        t.effective_from = Date.current
      end
    end
  end
end
