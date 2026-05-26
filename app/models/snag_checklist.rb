class SnagChecklist < ApplicationRecord
	has_many :snag_questions, dependent: :destroy
	accepts_nested_attributes_for :snag_questions, allow_destroy: true

	belongs_to :site, class_name: "SiteAsset", foreign_key: :site_id, optional: true
	belongs_to :fitout_category, class_name: "FitOutSetupCategory", foreign_key: :snag_audit_category_id, optional: true
end
