class OtherPAmenity < ApplicationRecord
  belongs_to :other_project

  has_one :amenity_icon, -> { where(relation: "OtherPAmenityIcon") },
          foreign_key: :relation_id,
          class_name: "Attachfile",
          dependent: :destroy
end
