class Complaint < ApplicationRecord
  serialize :project_email
  serialize :item_ids, Array
  belongs_to :category_type, class_name: "HelpdeskCategory",optional: true
  # belongs_to :sub_category, class_name: "HelpdeskSubCategory", optional: true
  # belongs_to :helpdesk_sub_category, class_name: "HelpdeskSubCategory", optional: true
  belongs_to :sub_category,
           class_name: "HelpdeskSubCategory",
           foreign_key: :sub_category_id,
           optional: true

belongs_to :helpdesk_sub_category,
           class_name: "HelpdeskSubCategory",
           foreign_key: :sub_category_id,
           optional: true

  belongs_to :complaint_status, foreign_key: :issue_status, optional: true
  belongs_to :tower, class_name: "Building", optional: true
  belongs_to :floor, class_name: "Floor", foreign_key: :wing_id, optional: true
  belongs_to :unit, class_name: "Unit", foreign_key: :unit_id, optional: true
  belongs_to :assigned_to_user, class_name: "User", foreign_key: :assigned_to, optional: true
  belongs_to :site, optional: true
  belongs_to :helpdesk_category, optional: true
  belongs_to :user, foreign_key: :id_user, class_name: 'User', optional: true
  belongs_to :complaint_mode, class_name: "ComplaintMode", foreign_key: :complaint_mode_id, optional: true
  delegate :name, to: :category_type, allow_nil: true
  delegate :tat, to: :category_type, allow_nil: true
  has_many :complaint_logs
  has_many :esc_histories
  has_many :cost_approval_requests
  has_many :ticket_items, foreign_key: :ticket_id
  has_many :feedbacks, -> { where(about: "ComplaintFeedback") }, :foreign_key => :about_id, class_name: "OsrLog"
  has_one :current_status, -> { order 'complaint_logs.id DESC' }, class_name: "ComplaintLog", :foreign_key => :complaint_id
  has_one :current_esc, -> { order 'id DESC' }, class_name: "EscHistory", :foreign_key => :complaint_id
  has_many :complaint_comments
  has_many :internal_complaint_comments, through: :complaint_logs
  has_many :attachments, -> { where(relation: "Complaint") }, :foreign_key => :relation_id, class_name: "Attachfile"
  has_many :documents, -> { where(relation: "Complaint") }, class_name: "Attachfile", foreign_key: :relation_id
  has_many :abouts, -> { where(about: "Complaint") }, :foreign_key => :about_id, :class_name => "SystemLog"
  ransacker :created_on do
    Arel.sql("DATE(#{table_name}.created_at)")
  end

  #
  # ransacker :search do |parent|
  #   adapter = ActiveRecord::Base.connection.adapter_name.downcase

  #   id_cast =
  #   case adapter
  #   when /mysql/, /maria/
  #     Arel.sql("CAST(complaints.id AS CHAR)")
  #   when /sqlserver/
  #     Arel.sql("CAST(complaints.id AS VARCHAR)")
  #   else # postgres
  #     Arel.sql("CAST(complaints.id AS TEXT)")
  #   end

  #   fields = [
  #     id_cast,
  #     parent.table[:heading],
  #     parent.table[:ticket_number],
  #     parent.table[:priority],
  #     parent.table[:issue_status],
  #     parent.table[:issue_related_to],
  #     parent.table[:complaint_type],
  #     parent.table[:of_phase],
  #     parent.table[:of_atype],
  #     parent.table[:society_staff_type],
  #     parent.table[:service_type],
  #     parent.table[:external_priority],
  #     parent.table[:reference_number],
  #     parent.table[:flat_number],
  #     parent.table[:project_email],
  #     parent.table[:additional_notes]
  #   ]

  #   if adapter.include?('mysql') || adapter.include?('maria')
  #     # MySQL: use CONCAT_WS so NULL fields are ignored instead of
  #     # turning the whole expression into NULL (which would kill the LIKE).
  #     segments = [Arel.sql("' '")] + fields
  #     Arel::Nodes::NamedFunction.new('CONCAT_WS', segments)
  #   else
  #     # PostgreSQL and others use || operator
  #     concatenated = fields.shift
  #     fields.each do |field|
  #       concatenated = Arel::Nodes::InfixOperation.new(
  #         '||',
  #         concatenated,
  #         Arel::Nodes::InfixOperation.new(
  #           '||',
  #           Arel.sql("' '"),
  #           field
  #         )
  #       )
  #     end
  #     concatenated
  #   end
  # end
  # validates :heading, :category_type_id, presence: true

  ransacker :search do |parent|
    adapter = ActiveRecord::Base.connection.adapter_name.downcase

    cast = ->(sql) {
      case adapter
      when /mysql/, /maria/
        Arel.sql("CAST(#{sql} AS CHAR)")
      when /sqlserver/
        Arel.sql("CAST(#{sql} AS VARCHAR)")
      else
        Arel.sql("CAST(#{sql} AS TEXT)")
      end
    }

    fields = [
      cast.call("complaints.id"),
      parent.table[:heading],
      parent.table[:ticket_number],
      parent.table[:priority],
      parent.table[:issue_related_to],
      parent.table[:complaint_type],
      parent.table[:of_phase],
      parent.table[:of_atype],
      parent.table[:society_staff_type],
      parent.table[:service_type],
      parent.table[:external_priority],
      parent.table[:reference_number],
      parent.table[:flat_number],
      parent.table[:project_email],
      parent.table[:additional_notes],

      # ===== Associated tables =====
      Arel.sql("helpdesk_categories.name"),
      Arel.sql("helpdesk_categories.id"),
      Arel.sql("helpdesk_sub_categories.name"),
      Arel.sql("helpdesk_sub_categories.id"),
      Arel.sql("complaint_statuses.name"),
      Arel.sql("complaint_statuses.id"),
      Arel.sql("buildings.name"),
      Arel.sql("buildings.id"),
      Arel.sql("floors.name"),
      Arel.sql("floors.id"),
      Arel.sql("units.name"),
      Arel.sql("units.id"),
      Arel.sql("sites.name"),
      Arel.sql("sites.id"),
      Arel.sql("users.firstname"),
      Arel.sql("users.id"),
      Arel.sql("users.lastname"),
      Arel.sql("assigned_users.lastname"),
      Arel.sql("assigned_users.id"),
      Arel.sql("assigned_users.firstname")
    ]

    if adapter.include?('mysql') || adapter.include?('maria')
      Arel::Nodes::NamedFunction.new(
        'CONCAT_WS',
        [Arel.sql("' '")] + fields
      )
    else
      concatenated = fields.shift
      fields.each do |field|
        concatenated =
        Arel::Nodes::InfixOperation.new(
          '||',
          concatenated,
          Arel::Nodes::InfixOperation.new(
            '||',
            Arel.sql("' '"),
            field
          )
        )
      end
      concatenated
    end
  end


  #validates :ticket_number, uniqueness: true

  before_save :check_if_assigned_to_not_zero
  after_create :assigned_to_mail_create, :update_unit_and_department_id
  after_update :update_response_resolution_time
  # Enqueue notifications only on create and when status actually changes
  after_commit -> { enqueue_notification_job('create') }, on: :create
  after_commit -> { enqueue_notification_job('status_change') }, on: :update, if: :saved_change_to_issue_status?
  after_create :set_auto_asignee_to_complaint
  before_create :set_issue_related
  after_initialize :init
  before_validation :check_ticket_number, on: :create
  after_create :set_escalation
  after_update :update_escalation, if: proc{|esc| esc.saved_change_to_priority? }
  after_update :set_issue_related_escalation , if: proc{|esc| esc.id_society.present? && esc.saved_change_to_issue_related_to? }
  after_update :set_category_type_escalation , if: proc{|esc| esc.id_society.present? && esc.saved_change_to_category_type_id? }

  after_update :send_notification_to_user #commented this to stop sending sms to complaint assigned to users

  delegate :formatted_reopen_time, to: :reopen_status, allow_nil: true

  scope :pms, ->{ where(of_phase: "pms") }
  scope :not_all_matrices, ->{ joins("LEFT OUTER JOIN `esc_histories` ON `esc_histories`.`complaint_id` = `complaints`.`id`").group('esc_histories.id').having('count(esc_histories.id) < ?', 3) }

  accepts_nested_attributes_for :attachments, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :cost_approval_requests, reject_if: proc { |attributes| attributes['cost'].blank? }, allow_destroy: true

  def init
  end

  def enqueue_notification_job(event_type)
    ComplaintNotificationJob.perform_later(self.id, event_type)
  end

  def send_notification_assign_to
    # Only proceed for creation or when issue_status changed
    return unless previous_changes.key?('id') || saved_change_to_issue_status?

    # Get company_id from complaint's site, fallback to assigned user's site
    company_id = self.site&.company_id || self.assigned_to_user&.site&.company_id

    # Build payloads depending on event (creation vs status update)
    if saved_change_to_issue_status? && !previous_changes.key?('id')
      status_name = ComplaintStatus.find_by_id(self.issue_status).try(:name)
      sendata = {
        title: "Ticket #{self.ticket_number} Status Updated",
        message: "Ticket #{self.ticket_number} is now #{status_name}",
        created_by: self.user.try(:full_name),
        ntype: "statuschangecomplaint",
        status_name: status_name,
        company_id: company_id,
        record_id: self.id,
        complaint_id: self.id
      }
    else
      sendata = {
        title: "Ticket #{self.ticket_number} Created",
        message: "New Ticket: #{self.heading} of priority #{self.priority} is Created",
        created_by: self.user.try(:full_name),
        ntype: self.complaint_type,
        company_id: company_id,
        record_id: self.id
      }
    end

    # Log and notify the explicitly assigned user (if present)
    Rails.logger.info("Complaint notification payload: #{sendata}")
    if self.assigned_to.present?
      PushNotification.push_to_devices(UserDevice.where(user_id: self.assigned_to), sendata)
    end

    # Also notify all site admins for the site immediately (batch device query)
    if self.site_id.present?
      admin_user_ids = UserSite.where(site_id: self.site_id).pluck(:user_id)
      admin_user_ids = User.where(id: admin_user_ids, user_type: ["pms_admin"]).pluck(:id)
      if admin_user_ids.any?
        admin_sendata = if saved_change_to_issue_status? && !previous_changes.key?('id')
          {
            title: "Complaint Status Updated",
            message: "Ticket #{self.ticket_number} status changed to #{ComplaintStatus.find_by_id(self.issue_status).try(:name)}",
            ntype: "complaint",
            status_name: ComplaintStatus.find_by_id(self.issue_status).try(:name),
            complaint_id: self.id,
            of_phase: self.of_phase,
            company_id: company_id,
            record_id: self.id
          }
        else
          {
            title: "New Complaint",
            message: "User has created a ticket of type #{self.complaint_type} has Ticket-ID #{self.id}",
            ntype: "complaint",
            complaint_id: self.id,
            of_phase: self.of_phase,
            company_id: company_id,
            record_id: self.id
          }
        end

        Rails.logger.info("Admin notification for #{admin_user_ids.count} users: #{admin_sendata}")
        PushNotification.push_to_devices(UserDevice.where(user_id: admin_user_ids), admin_sendata)
      end
    end
  end

  # def status
  #   ComplaintStatus.find_by_id(self.issue_status.to_i).try(:name)
  # end
  def check_if_assigned_to_not_zero
    if self.assigned_to == 0 || self.assigned_to == "0"
      self.assigned_to = self.assigned_to_was
    end
  end

  def self.having_current_status(status_id)
    select("complaints.*, MAX(complaint_logs.id) as M").joins(:complaint_logs).where(:complaint_logs => {:complaint_status_id => status_id}).group("complaint_logs.complaint_status_id").having("M = (select id from complaint_logs WHERE complaint_logs.complaint_id = complaints.id order by id desc limit 1)")
  end

  def current_fixed_state_for_pms
    if self.issue_status.present? && ComplaintStatus.find_by_id(self.issue_status).try(:fixed_state)== "complete"
      "complete"
    else
      ""
    end
  end

  def check_ticket_number
    ltn = Complaint.last.try(:ticket_number)
    if ltn.present?
      ntn = ltn.to_i + 1
      self.ticket_number = "#{ntn}"
    else
      self.ticket_number = "10001"
    end
    self.priority = "P1" if !self.priority.present?
    self.complaint_type = "Complaint" if !self.complaint_type.present?
    css = ComplaintStatus.find_or_create_by(society_id: self.site_id, name: "Pending")
    self.issue_status = css.id
    # self.complaint_logs.create(complaint_status_id: css.id)
  end

  def logs
    ComplaintLog.joins(:complaint_comments).where(complaint_id: self.id)
  end
  def calculate_resolution_tat
    # Determine the operations scope
    ops = site_id.present? ? HelpdeskOperation.site_ops(site_id) : HelpdeskOperation.soc_ops(society_id)

    # Fetch logs and response time
    logs = complaint_logs.where("complaint_status_id IS NOT NULL")
    resp_time = logs.second.try(:created_at) # Response time
    last_log = logs.try(:last)              # Last log for tracking updates

    # Calculate response TAT
    response_tat = response_tat_for(ticket_urgency, site_id) || 0

    # Fetch the complaint worker based on category, issue type, and site/society
    cws = if site_id.present?
      ComplaintWorker.where("esc_type IS NULL OR esc_type = 'resolution'")
      .where(category_id: category_type_id, society_id: site_id)
      .try(:last)
    else
      ComplaintWorker.where("esc_type IS NULL OR esc_type = 'resolution'")
      .where(issue_related_to: issue_related_to, issue_type_id: issue_type_id, category_id: category_type_id, society_id: id_society)
      .try(:last)
    end

    # Retrieve resolution matrix and TAT
    reso = EscalationMatrix.where(cw_id: cws.try(:id)).try(:first)
    resolution_tat = reso.try(priority.try(:downcase).try(:to_sym)) || 0

    # Complete status IDs for filtering
    complete_status_ids = if site_id.present?
      ComplaintStatus.pms.where(society_id: site_id, fixed_state: "complete").pluck(:id)
    else
      ComplaintStatus.pms.where(society_id: society_id, fixed_state: "complete").pluck(:id)
    end

    {
      response_tat: response_tat,
      resolution_tat: resolution_tat,
      logs: logs,
      last_log: last_log,
      complete_status_ids: complete_status_ids
    }
  end


  def update_response_resolution_time
    begin
      ops = self.site_id.present? ? HelpdeskOperation.site_ops(self.site_id) : HelpdeskOperation.soc_ops(self.society_id)  # Ensure correct usage of society_id
      logs = self.complaint_logs.where("complaint_status_id is not null")
      resp_time = logs.second.try(:created_at)
      last_log = logs.try(:last)
      response_tat = self.response_tat_for(self.ticket_urgency, self.site_id) || 0
      cws = if self.site_id.present?
        ComplaintWorker.where("esc_type is null or esc_type = 'resolution'").where(category_id: self.category_type_id, society_id: self.site_id).try(:last)  # Using society_id
      else
        ComplaintWorker.where("esc_type is null or esc_type = 'resolution'").where(issue_related_to: self.issue_related_to, issue_type_id: self.issue_type_id, category_id: self.category_type_id, society_id: self.id_society).try(:last)
      end
      reso = EscalationMatrix.where(cw_id: cws.try(:id)).try(:first)
      resolution_tat = reso.try(self.priority.try(:downcase).try(:to_sym)) || 0
      complete_status_ids = if self.site_id.present?
        ComplaintStatus.pms.where(society_id: self.site_id, fixed_state: "complete").pluck(:id)  # Using society_id
      end
      completed_lastlog = logs.where(complaint_status_id: complete_status_ids).order(created_at: :asc).last
      resol_time = if last_log.present? && %w(closed complete).include?(last_log.complaint_status.try(:fixed_state))
        if last_log.complaint_status.fixed_state == 'complete'
          last_log.created_at
        elsif last_log.complaint_status.fixed_state == 'closed' && completed_lastlog.present?
          completed_lastlog.created_at
        else
          last_log.created_at
        end
      else
        nil
      end
      resp_tat_time = EscalationMatrix.determine_time(self.created_at, ops, response_tat, true)
      resol_tat_time  =  EscalationMatrix.determine_time(self.created_at, ops, resolution_tat, true)
      self.update_columns(response_time: resp_time, resolution_time: resol_time, response_tat_time: resp_tat_time, resolution_tat_time: resol_tat_time)
    rescue Exception => e
      Rails.logger.error("This is error" + " " + e.inspect)
    end
  end

  def show_close_button
    cs = ComplaintStatus.find_by_id(self.issue_status)
    reopenstatus = ReopenStatus.find_by(society_id: self.id_society)
    if !society.close_by_user?
      false
    elsif cs.try(:fixed_state) == "complete"
      if reopenstatus.try(:time_seconds).present?
        close_time = self.complaint_logs.last.created_at
        closure_time = close_time + reopenstatus.time_seconds
        if Time.zone.now < closure_time
          true
        else
          !society.auto_complaint_close?
        end
      else
        !society.auto_complaint_close?
      end
    else
      false
    end
  end

  def ticket_urgency
    if urgency == 1
      "high"
    elsif urgency == 2
      "medium"
    elsif urgency == 3
      "low"
    else
      ""
    end
  end

  def latest_status
    self.issue_status.present? ? (ComplaintStatus.find_by_id(self.issue_status).try(:name) || self.issue_status ) : "pending"
  end

  def response_tat_for(urgency, site_id=nil)
    urgency_enabled = false
    (urgency_enabled && urgency.present?) ? category_type.try(:resp_tat, urgency) : issue_related_tat
  end

  def issue_related_tat
    if self.issue_related_to == 'Project'
      category_type.try(:project_tat)
    else
      category_type.try(:tat).try(:to_i)
    end
  end

  def update_unit_and_department_id
    self.update_columns(unit_id: self.user.unit.try(:id)) if self.user.present? && self.site_id.present? && !self.unit_id.present?
  end

  def set_auto_asignee_to_complaint
    if self.of_phase == "pms"
      @complaint_worker = ComplaintWorker.where(society_id: self.id_society, issue_type_id: self.issue_type_id, category_id: self.category_type_id, esc_type: nil)
      if @complaint_worker.present?
        self.assign_attributes(assigned_to: @complaint_worker.last.assign_to.present? ? @complaint_worker.last.assign_to.last : "")
      end
    end
    self.save if self.changed?
  end
  def send_notification_to_user
    # SystemLog.newlog(self, "Complaint Changes", self.changes, self)
    if saved_change_to_issue_status?
      #   sendata = { title: "Complaint status changed", message: "status of your Complaint is changed",  ntype: "statuschangecomplaint",  user_id: self.id_user, complaint_id: self.id }
      #   PushNotification.push_to_devices(UserDevice.where(user_id: self.id_user), sendata)
    end
    if saved_change_to_issue_related_to? && issue_related_to == "Project"
      all_emails = self.project_email
      all_emails.each do |emails|
        HelpdeskProjectMailer.new_helpdesk_emailer(emails, self).deliver_now
      end if all_emails.present?
    end
    if saved_change_to_assigned_to?
      notify_assigned_to
    end
  end

  def notify_assigned_to
    if assigned_to.present? && assigned_to != 0
      sendata = { title: "Complaint assigned", message: "New complaint is assigned to you",  ntype: "complaint",  user_id: self.assigned_to,company_id: self.site.company_id, record_id: self.id }
      PushNotification.push_to_devices(UserDevice.where(user_id: assigned_to), sendata)
    end
  end

  def checkpending
    if self.issue_status == nil
      if self.of_phase == "pms"
        cs = ComplaintStatus.pms.active.where(society_id: Pms::Site.find_by(id: self.site_id).company_id, name: "Pending")
        if cs.present?
          csid = cs.last
        else
          csid = ComplaintStatus.create(society_id:  Pms::Site.find_by(id: self.site_id).company_id, name: "Pending", active: 1, position: 0,of_phase: "pms")
        end
      else
        cs = ComplaintStatus.active.where(society_id: self.id_society, name: "Pending")
        if cs.present?
          csid = cs.last
        else
          csid = ComplaintStatus.create(society_id: self.id_society, name: "Pending", active: 1, position: 0)
        end
      end
      self.update_column(:issue_status, csid.id)
      self.complaint_logs.create(complaint_status_id: csid.id, priority: "P1", issue_related_to: self.issue_related_to)
    end
  end

  def set_escalation
    self.checkpending
    # self.send_notification_to_admin
    EscalationJob.set(wait_until: Time.zone.now + 1.minute).perform_later(self)
  end

  def set_issue_related_escalation
    update_escalation
  end

  def set_category_type_escalation
    update_escalation
  end

  def update_escalation
    EscalationJob.set(wait_until: Time.zone.now + 1.minute).perform_later(self)
  end

  # def send_notification_to_admin
  #   pms_notifications_create
  # end


  def pms_notifications_create
    if !self.assigned_to.present?
      cw = ComplaintWorker.pms.where(category_id: category_type.try(:id)).applicable_cw_for(self.category_type.try(:society_id), self.site_id)
      self.update(assigned_to: cw.try(:assignee_id), society_staff_type: "User")
    end
    notify_assigned_to
    if self.user.present?
      ComplaintMailer.pms_user_new_complaint(self).deliver_later(wait: 1.minute)
      sendata = { title: "Complaint received", message: "Your Complaint is received",  ntype: "pms_newcomplaint",  user_id: self.id_user, complaint_id: self.id, of_phase: self.of_phase, app_id: 15 }
      PushNotification.push_to_devices(UserDevice.where(user_id: self.id_user), sendata)
    end
    admin_users = User.where(id: UserSite.where(site_id: self.site_id).pluck(:user_id), user_type: ["pms_admin"])
    user_ids = admin_users.pluck(:id)
    user_ids.each_with_index do |adm, i|
      sendata = { title: "New Complaint", message: "You have new Complaint to check",  ntype: "pms_newcomplaintadmin",  user_id: adm, complaint_id: self.id, of_phase: self.of_phase, app_id: 15 }
      PushNotification.push_to_devices(UserDevice.where(user_id: adm), sendata)
    end
    ComplaintMailer.pms_admin_new_complaint(self, admin_users.pluck(:email)).deliver_later(wait: 1.minute)
  end

  def set_issue_related
    self.issue_related_to = "FM"
  end

  def reopen_status_for_pms
    @complaint_status = ComplaintStatus.find_by_id(self.issue_status)
    if @complaint_status.try(:fixed_state) == "complete"  && @reopenstatus.present?
      close_time = self.complaint_logs.last.created_at
      closure_time = close_time + @reopenstatus.time_seconds
      if Time.zone.now < closure_time
        true
      else
        false
      end
    else
      false
    end
  end

  def assigned_to_mail_create
    if self.site_id.present?
      if self.assigned_to.present?
        cws = ComplaintWorker.where("esc_type is null or esc_type = 'resolution'").where(issue_type_id: self.issue_type_id, category_id: self.category_type_id, society_id: self.site_id).try(:first)
        reso = EscalationMatrix.where(cw_id: cws.try(:id)).try(:first)
        resotat_min = reso.try(self.priority.try(:downcase).try(:to_sym))
        resptat_min = response_tat_for(ticket_urgency, site_id)
        resotat = self.dhm_new(resotat_min.present? ? resotat_min : 0)
        resptat = self.dhm_new(resptat_min.present? ? resptat_min : 0)
        ComplaintMailer.pms_assigned_to_complaint_mail(self,resptat,resotat).deliver_later
        ComplaintMailer.pms_complaint_worker_mail(self,resptat,resotat).deliver_later
      end
    end
  end

  def dhm_new(min)
    if min >= 1
      hh, mm = min.divmod(60)
      dd, hh = hh.divmod(24)
      str = ""
      if dd < 2 && dd > 0
        str += "#{dd} day "
      elsif dd >= 2
        str += "#{dd} days "
      end

      if hh < 2 && hh > 0
        str += "#{hh} hour "
      elsif hh >= 2
        str += "#{hh} hours "
      end

      if mm < 2 && mm > 0
        str += "#{mm.to_i} minute "
      elsif mm >= 2
        str += "#{mm.to_i} minutes "
      end
      return str
    else
      return 0
    end
  end

  private

  def complaint_log_params
    params.require(:complaint_log).permit(:complaint_id, :complaint_status_id, :priority, :assigned_to, :comment, :society_staff_type)
  end

end
