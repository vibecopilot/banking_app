class LoiDetail < ApplicationRecord
  has_many :loi_items
  belongs_to :vendor, optional: true
  belongs_to :user, foreign_key: 'created_by_id'
  belongs_to :billing_address, class_name: 'Address'
  belongs_to :delivery_address, class_name: 'Address'
  before_save :generate_pr_no
  has_many :approvals, as: :resource
  after_create :create_approval_log
  attr_accessor :approval_comment

  def create_approval_log
    Approval.create!(site_id: site_id, user_id: created_by_id, level_id: 1, status: "Pending", start_date: Date.current, end_date: nil, resource_id: self.id, resource_type: "LoiDetail", comments: loi_comments)
    self.update_column(:is_approved, "Submitted")
  end

  APPROVAL_STATUSES = {
    1 => "ProjectSiteApproved",
    2 => "AdminApproved",
    3 => "HOApproved",
    4 => "PromoterApproved"
  }.freeze

  def create_approval_levels(approved_by_user_id, level_id, comment=nil, approval_comment=nil)
    current_approval = approvals.where(level_id: level_id - 1, resource_id: self.id).last
    current_approval.update!(approved_by_id: approved_by_user_id, end_date: Date.current, comments: comment, status: APPROVAL_STATUSES[level_id - 1]) if current_approval.present?
    if level_id <= 4
      Approval.create!(
        site_id: site_id,
        user_id: created_by_id,
        level_id: level_id,
        status: APPROVAL_STATUSES[level_id],
        start_date: Date.current,
        end_date: nil,
        resource_id: self.id,
        resource_type: "LoiDetail",
        comments: comment,
        approved_by_id: approved_by_user_id,
        approver_comments: approval_comment
      )

      if level_id == 4
        self.update_column(:is_approved, "Approved")
      end

    end
  end

  private

  def generate_pr_no
    #binding.pry
    generic_code = GenericInfo.find_by(site_id: site_id, info_type: 'generate_material_no')
    codeval = generic_code.try(:name) || ""
    if generic_code
      sub_generic_code =  generic_code.generic_sub_infos.try(:first)
      new_val = (sub_generic_code.try(:name).present? ? (sub_generic_code.try(:name).to_i + 1) : self.id)
      self.pr_no = codeval.to_s + new_val.to_s
      if sub_generic_code.present?
        sub_generic_code.update(name: new_val)
      end
    else
      self.pr_no = "M-PR-#{self.id}"
    end
  end
end
