class QuotationLine < ApplicationRecord
  belongs_to :quotation, optional: true
end
