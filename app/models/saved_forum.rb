class SavedForum < ApplicationRecord
  belongs_to :user
  belongs_to :forum

  validates :user_id, uniqueness: { scope: :forum_id, message: "has already saved this forum." }

end
