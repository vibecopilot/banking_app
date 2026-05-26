class CostOfIncident < ApplicationRecord
  belongs_to :incident
  validates :total_cost, presence: true
end
