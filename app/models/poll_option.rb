class PollOption < ApplicationRecord
  belongs_to :poll
  has_many :poll_votes, dependent: :destroy

  validates :content, presence: true
  validates :poll, presence: true
end
