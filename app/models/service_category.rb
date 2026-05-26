class ServiceCategory < ApplicationRecord
  belongs_to :site
  has_many :service_subcategories, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :site_id }
  validates :sort_order, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }
  scope :for_site, ->(site_id) { where(site_id: site_id) }
  scope :ordered, -> { order(:sort_order, :name) }

  def subcategories_count
    service_subcategories.active.count
  end
end
