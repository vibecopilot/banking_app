class Capa < ApplicationRecord
  belongs_to :complaint, optional: true
  belongs_to :site, optional: true
  belongs_to :owner, class_name: "User", foreign_key: :owner_id, optional: true
  belongs_to :creator, class_name: "User", foreign_key: :created_by, optional: true

  scope :for_site, ->(site_id) { where(site_id: site_id) }
end
