class PermitActivitySetup < ApplicationRecord
  belongs_to :permit_type  , foreign_key: "parent_id"	
end
