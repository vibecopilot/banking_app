class AssetAmc < ApplicationRecord
  belongs_to :site_asset, foreign_key: :asset_id
  belongs_to :vendor
  has_many :terms, -> { where(relation: "AmcTerm") }, :foreign_key => :relation_id, class_name: "Attachfile"
  has_many :amc_contacts, dependent: :destroy
  has_many :amc_invoices, dependent: :destroy

  accepts_nested_attributes_for :amc_contacts, allow_destroy: true
  accepts_nested_attributes_for :amc_invoices, allow_destroy: true
end
