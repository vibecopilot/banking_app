class Incident < ApplicationRecord
  has_many :attachments, dependent: :destroy
  has_many :incident_injuries, dependent: :destroy
  has_many :witnesses, dependent: :destroy
  has_many :investigation_teams, dependent: :destroy
  has_one :cost_of_incident, dependent: :destroy
  belongs_to :user, foreign_key: "created_by_id" , optional:true
  belongs_to :building  , foreign_key: "Building",foreign_key: :building_id , optional:true

  accepts_nested_attributes_for :attachments, :witnesses, :investigation_teams, :cost_of_incident

end
