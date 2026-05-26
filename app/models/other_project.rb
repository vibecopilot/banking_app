class OtherProject < ApplicationRecord
has_many :likes, -> { where(resource_type: "OtherProject") }, :foreign_key => :resource_id, class_name: "Like", dependent: :destroy
has_many :other_p_amenities, dependent: :destroy
accepts_nested_attributes_for :other_p_amenities, allow_destroy: true

end
