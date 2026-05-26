class Permit < ApplicationRecord
    belongs_to :building, foreign_key: 'building_id', class_name: 'Building',optional: true
    belongs_to :floor, foreign_key: 'floor_id', class_name: 'Floor',optional: true
    belongs_to :site, foreign_key: 'site_id', class_name: 'Site',optional: true
    # belongs_to :permit_type, foreign_key: 'permit_type_id', class_name: 'PermitType',optional: true
    belongs_to :vendor, foreign_key: 'vendor_id', class_name: 'Vendor',optional: true
    belongs_to :unit, foreign_key: 'unit_id', class_name: 'Unit',optional: true
    belongs_to :created_by, foreign_key: 'created_by_id', class_name: 'User',optional: true
	has_many :permit_activities
end
