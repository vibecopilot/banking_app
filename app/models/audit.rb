class Audit < ApplicationRecord
	has_many :audit_tasks
	belongs_to :vendor, optional: true
	belongs_to :user, optional: true
	belongs_to :soft_service, optional: true
	belongs_to :site_asset, optional: true
end
