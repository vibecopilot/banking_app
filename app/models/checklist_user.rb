class ChecklistUser < ApplicationRecord
  belongs_to :user, class_name: "User", foreign_key: "user_id"
  belongs_to :checklist, class_name: "Checklist", foreign_key: "checklist_id"
end

