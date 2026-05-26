class SharedForum < ApplicationRecord
  belongs_to :forum
  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'

  validates :receiver_id, uniqueness: { scope: :forum_id, message: "Forum already shared with this user." }

end
