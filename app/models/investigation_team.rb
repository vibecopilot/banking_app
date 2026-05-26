class InvestigationTeam < ApplicationRecord
  belongs_to :incident
  validates :name, :mobile, :designation, presence: true
end