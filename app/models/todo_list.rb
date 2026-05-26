class TodoList < ApplicationRecord
	has_many :attachments, -> {where(relation: "TodoList")}, class_name: "Attachfile", foreign_key: :relation_id
end
