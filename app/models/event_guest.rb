class EventGuest < ApplicationRecord
  belongs_to :event
  belongs_to :visitor, optional: true
  belongs_to :vhost, class_name: 'User', foreign_key: 'vhost_id', optional: true
  
  validates :mobile_number, presence: true, length: { is: 10 }
  validates :mobile_number, uniqueness: { scope: :event_id }
  
  before_create :generate_invitation_token
  
  enum status: { invited: 0, registered: 1, pass_generated: 2 }
  
  private
  
  def generate_invitation_token
    self.invitation_token = SecureRandom.urlsafe_base64(32)
  end
end
