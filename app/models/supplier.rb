class Supplier < ApplicationRecord
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :site, class_name: 'Site', foreign_key: :site_id, optional: true
  has_many :ingredients, dependent: :nullify
  has_many :purchase_orders, dependent: :nullify
end
