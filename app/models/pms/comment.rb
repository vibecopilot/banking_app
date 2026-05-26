class Pms::Comment < ApplicationRecord
	belongs_to :occurrence, class_name: "Pms::AssetTaskOccurrence",
	foreign_key: "asset_task_occurrence_id"

	belongs_to :user, class_name: "User", foreign_key: "user_id"

	def user_name
		user.try(:fullname)
	end
end
