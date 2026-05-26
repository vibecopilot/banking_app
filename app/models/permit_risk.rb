class PermitRisk < ApplicationRecord
  belongs_to :permit_sub_activity, foreign_key: "sub_activity_id"	
  belongs_to :permit_activity_setup, foreign_key: "activity_id"	
  belongs_to :hazard_category, foreign_key: "hazard_category_id"
  belongs_to :permit_type, foreign_key: "permit_type_id"	
end
