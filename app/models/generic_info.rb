class GenericInfo < ApplicationRecord
	has_many :generic_sub_infos, dependent: :destroy
	accepts_nested_attributes_for :generic_sub_infos, allow_destroy: true
	has_many :contact_books
end
