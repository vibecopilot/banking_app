class AccountingInvoiceItem < ApplicationRecord
  # Associations
  belongs_to :accounting_invoice
  belongs_to :ledger, optional: true
  belongs_to :tax_rate, optional: true

  # Validations
  # No validations needed - fields are optional

  # Callbacks
  before_validation :map_service_description_to_description
  before_save :calculate_amounts
  after_save :update_invoice_totals
  after_destroy :update_invoice_totals

  # Instance methods
  def calculate_amounts
    # Use new GST fields if present, otherwise fall back to old logic
    if taxable_value.present? && total.present?
      # New GST-based calculation - use values from frontend
      self.amount = taxable_value.to_f
      self.tax_amount = (cgst_amount.to_f + sgst_amount.to_f + igst_amount.to_f)
      self.total_amount = total.to_f
    else
      # Old calculation for backward compatibility
      self.amount = (quantity || 1).to_f * (unit_price || 0).to_f
      self.tax_amount = if tax_rate
        tax_rate.calculate_tax(amount)
      else
        0.0
      end
      self.total_amount = amount + tax_amount
    end
  end

  private

  def map_service_description_to_description
    # Map service_description to description if description is blank
    self.description = service_description if description.blank? && service_description.present?
    # Map rate to unit_price if unit_price is blank
    self.unit_price = rate.to_f if unit_price.blank? && rate.present?
    
    # Ensure all numeric fields are properly formatted as floats
    self.quantity = quantity.to_f if quantity.present?
    self.rate = rate.to_f if rate.present?
    self.taxable_value = taxable_value.to_f if taxable_value.present?
    self.cgst_rate = cgst_rate.to_f if cgst_rate.present?
    self.cgst_amount = cgst_amount.to_f if cgst_amount.present?
    self.sgst_rate = sgst_rate.to_f if sgst_rate.present?
    self.sgst_amount = sgst_amount.to_f if sgst_amount.present?
    self.igst_rate = igst_rate.to_f if igst_rate.present?
    self.igst_amount = igst_amount.to_f if igst_amount.present?
    self.total = total.to_f if total.present?
  end

  def update_invoice_totals
    accounting_invoice.calculate_amounts
    accounting_invoice.save! if accounting_invoice.persisted?
  end
end
