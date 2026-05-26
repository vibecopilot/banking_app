class SiteModule < ApplicationRecord
  belongs_to :site
  belongs_to :role_modules
end
