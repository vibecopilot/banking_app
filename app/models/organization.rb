class Organization < ApplicationRecord
  has_many :companies, class_name: "Company"
end