class ComplaintComment < ApplicationRecord
	belongs_to :complaint
	belongs_to :user, :foreign_key => :changed_by, class_name: 'User'
	after_commit :enqueue_notification_job, on: :create

	has_many :docs, -> { where(relation: "ComplaintComment") }, class_name: "Attachfile", foreign_key: :relation_id
	has_many :attachments, -> { where(relation: "ComplaintComment") }, class_name: "Attachfile", foreign_key: :relation_id
	
	accepts_nested_attributes_for :docs, :attachments, reject_if: :all_blank, allow_destroy: true

	private

	def enqueue_notification_job
		# Enqueue job to run asynchronously
		ComplaintCommentNotificationJob.perform_later(self.id)
	end
end
