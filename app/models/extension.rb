class Extension < ApplicationRecord
  belongs_to :user  , foreign_key: "created_by_id" , optional:true
end
