class Question < ApplicationRecord
  belongs_to :group, class_name: "GenericInfo",:foreign_key => :group_id, optional: true
  # has_one :hint_attachment, -> { where(relation: "QuestionHint", active: true) }, class_name: "Attachfile",foreign_key: :relation_id
  has_one :hint_attachment,
    -> { where(relation: 'QuestionHint', active: true) },
    class_name: 'Attachfile',
    primary_key: :id,
    foreign_key: :relation_id
end
