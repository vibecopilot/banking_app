class Comment < ApplicationRecord
	belongs_to :task
	has_many :attachfiles, -> { where(relation: "Comment") }, :foreign_key => :relation_id, class_name: "Attachfile"
	accepts_nested_attributes_for :attachfiles, reject_if: :all_blank, allow_destroy: true
end
