class FitoutRequestCategory < ApplicationRecord
  belongs_to :fitout_request
  belongs_to :attachfile
  belongs_to :category_type, class_name: "FitOutSetupCategory", foreign_key: "category_type_id", optional: true

  # status: string, updated_by_id: integer
  
  def category_name
    category_type&.name
  end
end
