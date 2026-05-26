class OtherBill < ApplicationRecord
	belongs_to :vendor, foreign_key: 'vendor_id', class_name: 'Vendor',optional: true
end
