class QuotationHistory < ApplicationRecord
  belongs_to :quotation, optional: true
end
