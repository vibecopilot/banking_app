class ComplianceTagTask < ApplicationRecord
  belongs_to :compliance_tag, class_name: 'ComplianceTag', foreign_key: :compliance_tag_id

  has_one :attachment, -> { where(relation: "ComplianceTagTask") },
          foreign_key: :relation_id,
          class_name: 'Attachfile'
end
