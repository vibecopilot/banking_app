class PollVote < ApplicationRecord
  belongs_to :poll
  belongs_to :poll_option

  validates :poll_user_id, uniqueness: { scope: :poll_id, message: "has already voted in this poll" }
  validates :poll, presence: true
  validates :poll_option, presence: true

  validate :poll_is_active

  private

  def poll_is_active
    return if poll.start_date.blank? || poll.end_date.blank?

    if poll.start_date > Date.current || poll.end_date < Date.current
      errors.add(:poll, "is not currently active")
    end
  end
end