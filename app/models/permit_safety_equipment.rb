class PermitSafetyEquipment < ApplicationRecord
	belongs_to :activity,class_name:'PermitActivity',foreign_key: :activity_id
	belongs_to :sub_activity,class_name:'PermitSubActivity',foreign_key: :sub_activity_id
	belongs_to :hazard_category,class_name:'HazardCategory',foreign_key: :hazard_category_id
	belongs_to :permit_risk,class_name:'PermitRisk',foreign_key: :permit_risk_id
end
