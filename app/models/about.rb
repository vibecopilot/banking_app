class About < ApplicationRecord
	belongs_to :site, class_name:'Site',foreign_key: :site_id
end
