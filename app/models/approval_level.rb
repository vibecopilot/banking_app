class ApprovalLevel < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :site, optional: true
  belongs_to :approval, optional: true
  validates_uniqueness_of :order, scope: [:site_id], if: -> { approval_id.nil? && site_id.present? }
end
