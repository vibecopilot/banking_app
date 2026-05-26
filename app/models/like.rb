class Like < ApplicationRecord
  belongs_to :user
  belongs_to :forum, optional: true

  belongs_to :other_project,
             -> { where(resource_type: "OtherProject") },
             class_name: "OtherProject",
             foreign_key: "resource_id",
             optional: true

  validates :status, inclusion: { in: %w[liked unliked] }

  scope :liked, -> { where(status: 'liked') }
  scope :unliked, -> { where(status: 'unliked') }
end
