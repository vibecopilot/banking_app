class Poll < ApplicationRecord
  has_many :poll_options, dependent: :destroy
  has_many :poll_votes, dependent: :destroy
  belongs_to :group, class_name:'Group',foreign_key: :group_id, optional:true
  belongs_to :user , class_name: "User", foreign_key: :created_by_id, optional: true 
  validates :title, presence: true
  validates :start_date, :end_date, presence: true
  validate :end_date_after_start_date
  validate :poll_options_count
  has_many :poll_users, foreign_key: 'poll_id', dependent: :destroy
  accepts_nested_attributes_for :poll_options, reject_if: :all_blank, allow_destroy: true

  scope :active, -> { where("start_date <= ? AND end_date >= ?", Date.current, Date.current) }

  def results
    poll_options.map do |option|
      { option: option.content, votes: option.poll_votes.count }
    end
  end

  def active?
    start_date <= Date.current && end_date >= Date.current
  end


  def send_poll_notification
    # binding.pry
    case shared
    when 'individual'
      if poll_users.any?
        poll_users.each do |notice_user|
          PollMailer.poll_notification(notice_user.user, self).deliver_now if notice_user.user.present?
        end
      else
        PollMailer.poll_notification(self.user, self).deliver_now if self.user.present?
      end
    when 'group'
      if group_id.present? && group.present?
        group.group_members.include(:user).each do |group_member|
          user = group_member.user
          next unless user.present? && user.email.present?
          PollMailer.poll_notification(user, self).deliver_now if user.present?
        end
      end
    when 'all'
      poll_users&.each do |notice_user|
        PollMailer.poll_notification(notice_user.user, self).deliver_now if notice_user.user.present?
      end
    end
    # notify_assigned_to
  end

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?
    if end_date < start_date
      errors.add(:end_date, "must be after the start date")
    end
  end

  def poll_options_count
    if poll_options.size < 1
      errors.add(:poll_options, "must have at least one option")
    elsif poll_options.size > 5
      errors.add(:poll_options, "cannot have more than five options")
    end
  end
end
