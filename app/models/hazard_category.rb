class HazardCategory < ApplicationRecord
  belongs_to :permit_sub_activity , foreign_key: "sub_activity_id"	
  belongs_to :permit_activity_setup	 , foreign_key: "activity_id"	
end
