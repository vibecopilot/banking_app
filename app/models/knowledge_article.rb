class KnowledgeArticle < ApplicationRecord
  belongs_to :category, class_name: "HelpdeskCategory", foreign_key: :category_id, optional: true
  belongs_to :site, optional: true
  belongs_to :creator, class_name: "User", foreign_key: :created_by, optional: true

  serialize :tags

  scope :published, -> { where(status: "published") }
  scope :for_site, ->(site_id) { where(site_id: site_id) }
end
