class Notice < ApplicationRecord
  belongs_to :site
  belongs_to :group, class_name: 'Group', foreign_key: :group_id, optional: true
  has_many :notice_users, class_name: 'NoticeUser', foreign_key: 'notice_id'
  belongs_to :user , class_name: "User", foreign_key: :created_by_id, optional: true 
 
  after_create :notifying_users
  before_create :set_initial_status

  def set_initial_status
    update_status_based_on_time
  end


 def update_status_based_on_time
  now = Time.current

  self.status = if expiry_date.present?
    now < expiry_date ? 'upcoming' : 'expired'
  else
    'draft'
  end
end

  def send_notice_notification
   # binding.pry
  case shared
  when 'individual'
    
    if notice_users.any?
      notice_users.each do |notice_user|
        NoticeMailer.notice_notification(notice_user.user, self).deliver_now if notice_user.user.present?
      end
    else
      NoticeMailer.notice_notification(self.user, self).deliver_now if self.user.present?
    end

  when 'group'
    if group_id.present? && group.present?
      group.group_members.include(:user).each do |group_member|
        user = group_member.user
        next unless user.present? && user.email.present?
        NoticeMailer.notice_notification(user, self).deliver_now if user.present?
      end
    end

  when 'all'
    event_users&.each do |notice_user|
      NoticeMailer.notice_notification(notice_user.user, self).deliver_now if notice_user.user.present?
    end
  end
  # notify_assigned_to
end
p
  def notifying_users
    if self.shared == 'all'
      # Send to all users in the site
      all_users = User.joins(:user_sites).where(user_sites: { site_id: self.site_id }).distinct
      all_users.each do |user|
        sendata = { title: "New Notice Received!", message: "You have new notice to check", ntype: "notice", user_id: user.id, company_id: self.site.company_id, record_id: self.id }
        PushNotification.push_to_devices(UserDevice.where(user_id: user.id), sendata)
      end
    elsif self.notice_users.exists?
      self.notice_users.each do |user|
        sendata = { title: "New Notice Received!", message: "You have new notice to check", ntype: "notice", user_id: user.user_id, company_id: self.site.company_id, record_id: self.id }
        PushNotification.push_to_devices(UserDevice.where(user_id: user.user_id), sendata)
      end
    elsif self.group_id.present?
      users = self.group&.group_members
      if users.present?
        users.each do |user|
          sendata = { title: "New Notice Received!", message: "You have new notice to check", ntype: "notice", user_id: user.user_id, company_id: self.site.company_id, record_id: self.id }
          PushNotification.push_to_devices(UserDevice.where(user_id: user.user_id), sendata)
        end
      end
    end
  end
end