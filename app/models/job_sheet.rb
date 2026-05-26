class JobSheet < ApplicationRecord
  belongs_to :ticket, class_name: "Complaint", foreign_key: :ticket_id, optional: true
  belongs_to :site, optional: true
  belongs_to :creator, class_name: "User", foreign_key: :created_by, optional: true

  scope :for_site, ->(site_id) { where(site_id: site_id) }
end
