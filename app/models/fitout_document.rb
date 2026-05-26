class FitoutDocument < ApplicationRecord
  has_many :fitout_docs, -> { where(relation: 'FitoutDocument') }, class_name: 'Attachfile', foreign_key: 'relation_id'
end
