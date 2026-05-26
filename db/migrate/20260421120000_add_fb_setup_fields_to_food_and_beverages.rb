class AddFbSetupFieldsToFoodAndBeverages < ActiveRecord::Migration[5.2]
  def change
    change_table :food_and_beverages do |t|
      # Basic Details
      t.string  :email
      t.string  :gst_number

      # Restaurant Details
      t.string  :license_number
      t.string  :fssai_number
      t.string  :location_branch
      t.string  :delivery_zone
      t.float   :service_radius
      t.string  :tax_type

      # Floors / Areas
      t.string  :area_type, default: 'single'   # 'single' or 'multiple'

      # Payment Methods (stored as JSON array of strings)
      t.text    :payment_methods

      # UPI Details
      t.string  :gpay_upi
      t.string  :phonepe_upi
      t.string  :paytm_upi
    end
  end
end
