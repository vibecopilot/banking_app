class Witness < ApplicationRecord
  belongs_to :incident
  validates :name, :mobile, presence: true
end