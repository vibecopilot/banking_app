class CostApprovalRequest < ApplicationRecord

  validates :cost, presence: true
  belongs_to :complaint
  belongs_to :created_by, class_name: 'Spree::User', foreign_key: :created_by_id
  has_many :cost_approval_histories, dependent: :destroy
  has_many :attachments, -> { where(relation: "CostApprovalRequest") }, :foreign_key => :relation_id, class_name: "Attachfile"

  accepts_nested_attributes_for :attachments, reject_if: :all_blank, allow_destroy: true
  scope :active, -> {where(active: true)}

  after_create :send_cost_approval_mail

  def send_cost_approval_mail
    cost_approvals = CostApproval.active.applicable_approvals(complaint.issue_related_to, complaint.pms_company_setup.try(:cost_approval_level)).approvals_for(complaint.pms_company_setup.try(:id))
    abblicable_ca_id = cost_approvals.matched_cost_approval_for(self.cost)
    cost_approval_levels = CostApprovalLevel.where(cost_approval_id: abblicable_ca_id).where.not(escalate_to_users: [""])
    approved_level_ids = CostApprovalHistory.where(status: :approved, cost_approval_request_id: self.id).pluck(:cost_approval_level_id)
    level = cost_approval_levels.where.not(id: approved_level_ids).order(created_at: :desc).first
    if level.present?
      approval_history = CostApprovalHistory.create(cost_approval_level_id: level.id, cost_approval_request_id: self.id)
      level.escalate_to_users.map(&:to_s).reject(&:empty?).each do |u|
        user = Spree::User.find_by(id: u)
        if self.created_by.try(:user_type) == "pms_admin" && self.created_by_id == user.id
        else
          CostApprovalMailer.cost_approval_request_mail(self, approval_history, user).deliver
        end
      end
    end
  end

end