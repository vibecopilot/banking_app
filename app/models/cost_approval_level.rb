class CostApprovalLevel < ApplicationRecord

	serialize :escalate_to_users
	belongs_to :cost_approval
	has_many :cost_approval_histories

	after_create :update_escalation_users

	def update_escalation_users
		if self.access_level.present?
			users = Spree::User.active_lups(cost_approval.resource_id).fm_users.where('lock_user_permissions.access_level =?', self.access_level)
			self.update_columns(escalate_to_users: users.pluck(:id))
		end
	end
end