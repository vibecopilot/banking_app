class MomDetail < ApplicationRecord
  has_many :mom_tasks, dependent: :destroy
  has_many :mom_attendees, dependent: :destroy

  accepts_nested_attributes_for :mom_tasks, allow_destroy: true
  accepts_nested_attributes_for :mom_attendees, allow_destroy: true

  validates :title, :meeting_date, :created_by_id, presence: true
end
