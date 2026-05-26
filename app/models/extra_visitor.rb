class ExtraVisitor < ApplicationRecord
	belongs_to :visitor
	#validates :name, :contact_no, presence: true
end
