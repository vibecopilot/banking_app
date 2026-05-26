class InvoiceSetup < ApplicationRecord
	  # Default value for the field
  after_initialize :set_defaults, if: :new_record?

  private

  def set_defaults
    self.online_payment_allowed = false if online_payment_allowed.nil?
  end
end
