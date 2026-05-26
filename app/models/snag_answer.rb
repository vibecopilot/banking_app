class SnagAnswer < ApplicationRecord
	belongs_to :users, class_name: "User", foreign_key: :user_id, optional: true
	belongs_to :snag_question , class_name: "SnagQuestion", foreign_key: :question_id, optional: true
end
