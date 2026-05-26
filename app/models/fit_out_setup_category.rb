class FitOutSetupCategory < ApplicationRecord
      has_one :attachfile, ->{where(relation: "FitOutSetupCategoryIcon") }, :foreign_key => :relation_id, :class_name => "Attachfile"
end
