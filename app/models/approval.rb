class Approval < ApplicationRecord
  belongs_to :user
  belongs_to :approval_level, foreign_key: :level_id, optional: true
  belongs_to :site
  belongs_to :approved_by, class_name: "User", optional: true
  has_many :approval_levels, -> { order(:order) }, foreign_key: :approval_id, dependent: :nullify

  accepts_nested_attributes_for :approval_levels, allow_destroy: true
end
