class VisitorGroupInvite < ApplicationRecord
  belongs_to :site
  belongs_to :invited_by, class_name: 'User', foreign_key: 'invited_by_id'
  has_many :visitor_group_invite_guests, dependent: :destroy
  
  validates :invited_by_id, :site_id, presence: true
  
  # Send SMS invitations to all guests
  def send_invitations
    VisitorGroupInviteJob.perform_later(id)
  end
end
