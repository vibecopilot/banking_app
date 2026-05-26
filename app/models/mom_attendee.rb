class MomAttendee < ApplicationRecord
  belongs_to :mom_detail

  validates :name, :email, presence: true
end
