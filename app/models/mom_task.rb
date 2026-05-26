class MomTask < ApplicationRecord
  belongs_to :mom_detail

  validates :description, :responsible_person_name, presence: true
end
