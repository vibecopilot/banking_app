class PermitSubActivity < ApplicationRecord
  belongs_to :permit_type
  belongs_to :permit_activity_setup
end
