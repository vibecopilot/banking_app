class IncidentInjury < ApplicationRecord
	belongs_to :incident, class_name:'Incident', foreign_key: :incident_id
end
