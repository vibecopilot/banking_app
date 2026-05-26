class Forum < ApplicationRecord
  has_many :forum_comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user
  scope :visible, -> { where(visible: true).order(created_at: :desc) }
  scope :hidden, -> { where(visible: false) }
  has_many :reports, class_name: 'ForumReport', dependent: :destroy
  has_many :saved_forums, dependent: :destroy
  has_many :savers, through: :saved_forums, source: :user
  belongs_to :creator, class_name: "User", foreign_key: "created_by_id", optional: true
  has_many :forum_documents, -> { where(relation: 'ForumDocument') }, class_name: "Attachfile", primary_key: "id", foreign_key: "relation_id", dependent: :destroy
  has_one :forum_profile, -> { where(relation: 'ForumProfile') }, class_name: "Attachfile", primary_key: "id", foreign_key: "relation_id", dependent: :destroy


  def report(reason, user)
    reports.create(reason: reason, reported_by: user)
  end

    # Comment count method
  def comment_count
    forum_comments.count
  end

  # Likes count method
  def likes_count
    likes.count
  end

end