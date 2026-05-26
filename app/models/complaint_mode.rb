class ComplaintMode < ApplicationRecord

  has_many :complaints
  # validates :name, presence: true
  validates_uniqueness_of :name
  scope :pms, ->{ where(of_phase: "pms") }

  def self.active
		where("active is null or active !=0")
	end
end
