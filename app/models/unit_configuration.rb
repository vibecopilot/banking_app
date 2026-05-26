class UnitConfiguration < ApplicationRecord
  belongs_to :site
  has_many :units, dependent: :nullify
  has_many :service_pricings, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :site_id }
  #validates :bedrooms, :bathrooms, :halls, :kitchens, numericality: { greater_than_or_equal_to: 0 }
  #validates :carpet_area, :built_up_area, numericality: { greater_than: 0 }, allow_blank: true

  scope :active, -> { where(active: true) }
  scope :for_site, ->(site_id) { where(site_id: site_id) }

  def display_name
    "#{name} (#{bedrooms}BR #{bathrooms}BA)"
  end

  def area_info
    return nil unless carpet_area.present? || built_up_area.present?
    
    parts = []
    parts << "Carpet: #{carpet_area} sq ft" if carpet_area.present?
    parts << "Built-up: #{built_up_area} sq ft" if built_up_area.present?
    parts.join(", ")
  end
end
