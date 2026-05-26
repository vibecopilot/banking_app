class SnagQuestion < ApplicationRecord
  belongs_to :snag_checklist
  has_many :snag_quest_options, dependent: :destroy
  accepts_nested_attributes_for :snag_quest_options, allow_destroy: true
end
