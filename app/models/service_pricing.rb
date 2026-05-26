class ServicePricing < ApplicationRecord
  belongs_to :service_subcategory
  belongs_to :unit_configuration
  has_many :service_bookings, dependent: :destroy

  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :discount_percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :tax_percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  scope :active, -> { where(active: true) }

  # Before save calculations
  before_save :calculate_amounts

  def calculate_amounts
    # Calculate discount amount
    self.discount_amount = (price * (discount_percentage || 0) / 100).round(2)
    
    # Calculate discounted price
    discounted_price = price - discount_amount
    
    # Calculate tax amount on discounted price
    self.tax_amount = (discounted_price * (tax_percentage || 0) / 100).round(2)
    
    # Calculate final price
    self.final_price = discounted_price + tax_amount
  end

  def discounted_price
    return price if discount_percentage.nil? || discount_percentage.zero?
    
    price - (price * discount_percentage / 100)
  end

  def savings_amount
    return 0 if discount_percentage.nil? || discount_percentage.zero?
    
    price * discount_percentage / 100
  end

  def price_breakdown
    {
      original_price: price || 0,
      discount_percentage: discount_percentage || 0,
      discount_amount: discount_amount || 0,
      discounted_price: discounted_price,
      tax_percentage: tax_percentage || 0,
      tax_amount: tax_amount || 0,
      final_price: final_price || price || 0
    }
  end
end
