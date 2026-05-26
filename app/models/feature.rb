class Feature < ApplicationRecord
	belongs_to :site
	validates_presence_of :feature_name
	validates_uniqueness_of :feature_name, scope: :site_id
end
