class VisitorSubCategory < ApplicationRecord
  belongs_to :visitor_category
  has_many :visitors

  validates :name, presence: true

  has_one :iconv2, -> {where(relation: "VisitorSubCategory")}, foreign_key: :relation_id, class_name: "Attachfile"

  accepts_nested_attributes_for :iconv2, allow_destroy: true

end
