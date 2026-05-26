class BillingConfiguration < ApplicationRecord
  belongs_to :site
  has_one :logo, -> { where(relation: "BillingConfiguration") }, foreign_key: :relation_id, class_name: "Attachfile"
  
  # Validations
  validates :site_id, presence: true
  validates :company_name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :gst_number, format: { with: /\A[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}\z/ }, allow_blank: true
  validates :pan_number, format: { with: /\A[A-Z]{5}[0-9]{4}[A-Z]{1}\z/ }, allow_blank: true
  validates :pincode, format: { with: /\A[0-9]{6}\z/ }, allow_blank: true
  validates :ifsc_code, format: { with: /\A[A-Z]{4}0[A-Z0-9]{6}\z/ }, allow_blank: true
  
  # File upload for company logo
  # Assuming you're using ActiveStorage or CarrierWave
  # has_attached_file :company_logo_file if using ActiveStorage
  
  # Get default configuration for site
  def self.default_for_site(site)
    site.billing_configurations.first_or_create(
      company_name: site.name,
      email: site.email,
      phone: site.phone_number,
      address: site.address
    )
  end
  
  # Check if configuration is complete
  def complete?
    company_name.present? && 
    gst_number.present? && 
    bank_name.present? && 
    account_number.present? && 
    ifsc_code.present?
  end

  # Convenience flags for GST handling
  def gst_split_enabled?
    !!enable_gst_split
  end

  def igst_enabled?
    !!enable_igst
  end
end
