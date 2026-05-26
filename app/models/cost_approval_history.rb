class CostApprovalHistory < ApplicationRecord

  validates :cost_approval_level_id, :cost_approval_request_id, presence: true

  belongs_to :cost_approval_level
  belongs_to :cost_approval_request
  belongs_to :updated_by, class_name: 'Spree::User', foreign_key: :updated_by_id


 


  after_update :send_approved_email, if: proc{|s| s.saved_change_to_status? && s.approved?}
  after_update :send_rejected_email, if: proc{|s| s.saved_change_to_status? && s.rejected?}
  after_update :send_cancellation_mail, if: proc{|s| s.saved_change_to_status? && s.cancelled?}

  after_create :create_logs, if: proc{|s| s.pending?}
  after_update :create_logs


  delegate :name, to: :cost_approval_level, prefix: true, allow_nil: true


    def send_cancellation_mail
      emails = []
      @users = []
      level = self.cost_approval_level
      if level.present?
        cost_approval_request.cost_approval_histories.each do |history|
          if history.cost_approval_level.try(:name).tr("^0-9", '').to_i <= level.try(:name).tr("^0-9", '').to_i
             users = history.cost_approval_level.escalate_to_users.map(&:to_s).reject(&:empty?)
             email = Spree::User.where(id: users).pluck(:email)
             emails << email
          end
        end
        emails << cost_approval_request.created_by.try(:email)
        emails =  emails.uniq.join(",")
        @users = emails
      else
        @users = cost_approval_request.created_by.try(:email)
      end
      @users.split(",").each do |u| 
        user = Spree::User.find_by(email: u)
          CostApprovalMailer.cost_approval_cancellation_mail(self,cost_approval_request,user).deliver
      end
    end

    def send_approved_email
      cost_approval_request.send_cost_approval_mail
      CostApprovalMailer.cost_approval_confirmation_mail(self, cost_approval_request,cost_approval_request.created_by).deliver
    end


    def send_rejected_email    
      emails = []
      @users = []
      level = self.cost_approval_level
      if level.present?
        cost_approval_request.cost_approval_histories.each do |history|
          if history.cost_approval_level.try(:name).tr("^0-9", '').to_i <= level.try(:name).tr("^0-9", '').to_i
             users = history.cost_approval_level.escalate_to_users.map(&:to_s).reject(&:empty?)
             email = Spree::User.where(id: users).pluck(:email)
             emails << email
          end
        end
        emails << cost_approval_request.created_by.try(:email)
        emails =  emails.uniq.join(",")
        @users = emails
      else
        @users = cost_approval_request.created_by.try(:email)
      end
      @users.split(",").each do |u| 
        user = Spree::User.find_by(email: u)
          CostApprovalMailer.cost_approval_confirmation_mail(self, cost_approval_request,user).deliver
      end
    end


   def create_logs
    SystemLog.newlog(self, self.status, self.saved_changes, self.cost_approval_request)
  end
end