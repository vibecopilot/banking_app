class ForumReport < ApplicationRecord
  belongs_to :forum
  belongs_to :reported_by, class_name: 'User'

  validates :reason, presence: true
end