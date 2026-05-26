class VisitorGroupInviteGuest < ApplicationRecord
  belongs_to :visitor_group_invite
  belongs_to :visitor, optional: true
  
  validates :mobile_number, presence: true, length: { is: 10 }
  
  before_create :generate_invitation_token
  
  enum status: { invited: 0, registered: 1, pass_generated: 2 }
  
  private
  
  def generate_invitation_token
    self.invitation_token = SecureRandom.urlsafe_base64(32)
  end
end
