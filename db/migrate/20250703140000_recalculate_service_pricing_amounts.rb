class RecalculateServicePricingAmounts < ActiveRecord::Migration[5.1]
  def up
    # Recalculate pricing amounts for all existing service_pricings
    ServicePricing.find_each do |pricing|
      pricing.save! # This will trigger the before_save callback to calculate amounts
    end
  end

  def down
    # No-op for down migration
  end
end
