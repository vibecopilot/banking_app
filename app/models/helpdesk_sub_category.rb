class HelpdeskSubCategory < ApplicationRecord
  belongs_to :helpdesk_category
  has_many :complaints
  def self.active
		where("active is null or active !=0")
	end
end
