module Pms
  class ComplaintsController < ApplicationController
    include UserExt
    layout 'basic'
    before_action :authenticate_user!, if: :check_user
    before_action :api_user
    before_action :set_user
    before_action :set_complaint, only: [:show, :edit, :update, :destroy]

    # def index
    #   if params[:q].present? && params[:q][:date_range].present?
    #    @date_range = params[:q][:date_range].split(" - ")
    #    params[:q][:created_at_lteq] = Date.strptime(@date_range[1], "%m/%d/%Y").strftime("%d/%m/%Y")
    #    params[:q][:created_at_gteq] = Date.strptime(@date_range[0], "%m/%d/%Y").strftime("%d/%m/%Y")
    #   end
    #   @per_page = params[:per_page]  || 20
    #   if @user.pms_occupant_admin? && params["format"] != "json"
    #     options = if @user.lock_user_permission.try(:entity).present?
    #       {unit_id_in: @user.lock_user_permission.entity.try(:units).pluck(:id)}
    #     elsif @user.lock_user_permission.try(:pms_unit).present?
    #       {unit_id_in: @user.lock_user_permission.pms_unit.id}
    #     else
    #       {site_id_in: @user.current_site_id}
    #     end
    #     @user_complaints = Complaint.pms.ransack(options).result
    #   else
    #     @user_complaints = Complaint.pms.ransack(id_user_or_assigned_to_eq: @user.id).result
    #   end
    #   @complaints = @user_complaints.ransack(params[:q]).result.page(params[:page]).per(@per_page).order("created_at DESC")
    #   if params["format"] == "json"
    #     render "pms/manage/complaints/user_helpdesk"
    #    else
    #     respond_to do |format|
    #        format.html { render layout: 'basic' }
    #     end
    #   end
    # end

    def index
      if params[:q].present? && params[:q][:date_range].present?
        date_range = params[:q][:date_range].split(" - ")
        params[:q][:created_at_gteq] =
          Date.strptime(date_range[0], "%m/%d/%Y").beginning_of_day
        params[:q][:created_at_lteq] =
          Date.strptime(date_range[1], "%m/%d/%Y").end_of_day
      end
      @per_page = (params[:per_page] || 20).to_i
      if @user.pms_occupant_admin? && params[:format] != "json"
        options =
        if @user.lock_user_permission&.entity.present?
          { unit_id_in: @user.lock_user_permission.entity.units.pluck(:id) }
        elsif @user.lock_user_permission&.pms_unit.present?
          { unit_id_in: @user.lock_user_permission.pms_unit.id }
        else
          { site_id_in: @user.current_site_id }
        end
        @user_complaints = Complaint.pms.ransack(options).result
      else
        @user_complaints =
          Complaint.pms.ransack(id_user_or_assigned_to_eq: @user.id).result
      end
      @complaints =
      @user_complaints.left_joins(
        :category_type,
        :sub_category,
        :helpdesk_sub_category,
        :complaint_status,
        :site,
        :user,
        :unit
      ).joins(
        "LEFT JOIN users assigned_users ON assigned_users.id = complaints.assigned_to"
      ).includes(
        :complaint_status,
        :helpdesk_category,
        :helpdesk_sub_category,
        { unit: [:building, :floor] },
        :user,
        :site,
        { complaint_logs: { complaint_comments: :attachments } },
        :attachments
      ).ransack(params[:q]).result
      .order(created_at: :desc)
      .page(params[:page])
      .per(@per_page)
      if params[:format] == "json"
        render "pms/manage/complaints/user_helpdesk"
      else
        render layout: "basic"
      end
    end

    def get_complaint
      @complaints = Complaint.pms.where(site_id: @user.current_site_id).ransack(params[:q]).result
      respond_to do |format|
        format.json { render "pms/manage/complaints/user_helpdesk" }
      end
    end

    # GET /complaints/1
    def show
      add_breadcrumb "Tickets", "/pms/complaints"
      add_breadcrumb "Details"
      @complaint_modes = ComplaintMode.pms.active
      @pms_suppliers = Vendor.where(company_id: @user.company_id)
      if params["format"] == "json"
        render "pms/manage/complaints/show"
      end
    end

    def complaint_edit_form
      @complaint = Complaint.find(params[:id])
      @complaint_modes = ComplaintMode.pms.active.where(society_id: @user.company_id)
      @pms_suppliers = Vendor.where(company_id: @user.company_id)
      @user_society_admin = UserSociety.where(id_society: @curusoc.id_society,role_id: [11,21])
    end

    # GET /complaints/new
    def new
      add_breadcrumb "Tickets", "/pms/complaints"
      add_breadcrumb "New Ticket"
      @complaint = Complaint.new
    end

    def feeds
      @complaint = Complaint.find_by(id: params[:id])
      @abouts = @complaint.abouts.order("id desc").group_by {|i| i.created_at.to_date}
    end

    # GET /complaints/1/edit
    def edit
    end

    # POST /complaints
    # POST /complaints.json
    def create

      puts "========================================"
      if (params[:complaint].present? && params[:complaint][:on_behalf_of] == "user") || params[:on_behalf_of] == "user"
        @complaint = Complaint.new(complaint_params.merge(:id_user => params[:sel_id_user], :site_id => @user.current_site_id,:created_by => @user.id))
      else
        @complaint = Complaint.new(complaint_params.merge(:id_user => @user.id, :site_id => @user.current_site_id,:created_by => @user.id))
      end
      if @complaint.site_id.to_i == 25
        @complaint.person_id = 209
      end

      respond_to do |format|
        if @complaint.save
          # binding.pry
          if @complaint.assigned_to.blank?
            user = GenericInfo.find_by(site_id: @user.current_site_id, info_type: "SiteOwner")
            @complaint.update(assigned_to: user.name.to_i) if user.present? # or user.try(:name) if it's a name field
          end
          #   if params[:documents].present?
          #   params[:documents].each do |doc|
          #     Attachfile.create(image: doc, relation: "Complaint", relation_id: @complaint.id, active: 1)
          #   end
          # end
          if params[:documents].present?
            params[:documents].each do |doc|
              Attachfile.create!(
                image: doc,
                relation: "Complaint",
                relation_id: @complaint.id,
                active: 1
              )
            end
          end
          if params[:attachments].present?
            params[:attachments].each do |doc|
              Attachfile.create(image: doc, relation: "Complaint", relation_id: @complaint.id, active: 1)
            end
          end
          format.html { redirect_to "/pms/complaints/#{@complaint.id}", notice: 'Complaint was successfully created.' }
          format.json { render "/pms/manage/complaints/show", status: :created}
        else
          format.html { render :new }
          format.json { render json: @complaint.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /complaints/1
    # PATCH/PUT /complaints/1.json
    def update
      respond_to do |format|
        if @complaint.update(complaint_params)
          if params[:documents].present?
            Attachfile
              .where(id: params[:documents], relation: "Complaint", relation_id: @complaint.id)
              .destroy_all
            params[:documents].each do |file|
              Attachfile.create!(
                image: file,
                relation: "Complaint",
                relation_id: @complaint.id,
                active: 1
              )
            end
          end
          format.html { redirect_to "/pms/complaints", notice: 'Complaint was successfully updated.' }
          format.json { render :show, status: :ok }
        else
          format.html { render :edit }
          format.json { render json: @complaint.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /complaints/1
    # DELETE /complaints/1.json
    def destroy
      @complaint.update(active: 0)
      respond_to do |format|
        format.html { redirect_to complaints_url, notice: 'Complaint was successfully destroyed.' }
        format.json { render json: { "code":200, "message":"Deleted Successfully" } }
      end
    end

    def admin_helpdesk
      user = User.find_by_api_key(params[:token])
      if user
        society_admin_id = exclude_spree_class('Role').society_admin.id
        soc_id = user.user_societies.where(role_id: society_admin_id).pluck(:id_society)
        @complaints = Complaint.pms.where(id_society: soc_id).order("id DESC")
      else
        render json: {"code":401, "error":"Not Authorised"}
      end
    end

    def user_helpdesk
      user_id = User.find_by_api_key(params[:token]).try(:id)
      if user_id.present?
        @complaints = Complaint.pms.where(id_user: user_id).order("id DESC")
      else
        render json: {"code":401, "error":"Not Authorised"}
      end
    end

    def get_complaint_constants
      @category_type = CategoryType.order(:id).pluck(:name)
    end

    def reports
      if params[:q].present? && params[:q][:date_range].present?
        @date_range = params[:q][:date_range].split(" - ")
        params[:q][:created_at_lteq] = Date.strptime(@date_range[1], "%m/%d/%Y").strftime("%d/%m/%Y")
        params[:q][:created_at_gteq] = Date.strptime(@date_range[0], "%m/%d/%Y").strftime("%d/%m/%Y")
      end

      if params[:commit] == "export"
        colomns_for_export = params[:q][:to] << "Response TAT Breached" << "Resolution TAT Breached"
        sibs = Society.siblings(@curusoc.id_society)
        @soc = Complaint.pms.where(:id_society => sibs).search(params[:q]).result
        @respbreached = @soc.search(esc_histories_escalation_matrix_complaint_worker_esc_type_eq: "response").result.uniq.pluck(:id)
        # @respachieved = @soc_1.where.not(id: @respbreached).pluck(:id)
        @resolutionbreached = @soc.search(esc_histories_escalation_matrix_complaint_worker_esc_type_eq: "resolution").result.uniq.pluck(:id)
        # @resolutionchieved = @soc_1.where.not(id: @resolutionbreached).pluck(:id)

        # @extra_soc = []

        # if params[:response_tat] == "breached"
        #   @extra_soc = (@extra_soc_response <<  @respbreached)
        # elsif params[:response_tat] == "acheived"
        #   # byebug
        #   @extra_soc = (@extra_soc_response <<  @respachieved)
        # end

        # if params[:resolution_tat] == "breached"
        #   @extra_soc = (@extra_soc_resolution <<  @resolutionbreached)
        # elsif params[:resolution_tat] == "acheived"
        #   @extra_soc = (@extra_soc_resolution <<  @resolutionchieved)
        # end

        # if(params[:response_tat] .present? && params[:resolution_tat].present?)
        #   @extra_soc = @extra_soc_response + @extra_soc_resolution
        # end

        # @soc = Complaint.where(id: @extra_soc).search(params[:q]).result

        @formated = CSV.generate do |csv|
          csv << colomns_for_export
          @soc.each do |soc|
            cd = soc.created_at.strftime('%d/%m/%Y')
            ct = soc.created_at.strftime('%l: %M %p')
            cws = ComplaintWorker.where(issue_type_id: soc.issue_type_id, category_id: soc.category_type_id).try(:first)
            #staff = cws.present? ? SocietyStaff.find_by_id(cws.assign_to.try(:first)) : nil
            assgnd = soc.society_staff.try(:full_name)
            cs = soc.current_status
            cm = soc.complaint_comments
            cmt = cm.present? ? cm.last.comment: ""
            if soc.urgency == 1
              ur = "High"
            elsif soc.urgency == 2
              ur = "Medium"
            elsif soc.urgency == 3
              ur = "Low"
            end

            cit = soc.issue_type_id.present? ? IssueType.find_by(id: soc.issue_type_id).try(:name) : ""
            cct = soc.try(:complaint_type)

            cb = soc.user_society
            csb = (cb.present? && cb.user_flat.present?) ? cb.user_flat.society_flat.try(:society_block).try(:name): ""
            csf = (cb.present? && cb.user_flat.present?) ? cb.user_flat.society_flat.try(:flat_no) : ""
            csn = cs.try(:name)
            csun = cs.present? ? cs.user.try(:full_name) : ""
            csd = cs.try(:created_at).present? ? cs.created_at.strftime('%d/%m/%Y') : ""
            cst = cs.try(:created_at).present? ? cs.created_at.strftime('%l: %M %p') : ""
            prio = soc.try(:priority) #priority
            reso = EscalationMatrix.where(cw_id: cws.try(:id)).try(:first)
            resotat = reso.try(:p1)  #resolution tat
            clog = ComplaintLog.where(complaint_id: soc.id).where("complaint_status_id is not null").try(:second)
            crtime = soc.created_at
            resptime = nil #respons etime
            if clog.present?
              clogtime = clog.created_at
              resptime = ((clogtime - crtime) / 60).to_i
            end
            resolutime = nil #resolution time
            lastlog = ComplaintLog.where(complaint_id: soc.id).where("complaint_status_id is not null").try(:last)
            if lastlog.present? && lastlog.complaint_status_id.present? && lastlog.complaint_status.try(:fixed_state) == "closed"
              lasttime = lastlog.created_at
              resolutime = ((lasttime - crtime) / 60).to_i
            end

            eh = EscHistory.where(complaint_id: soc.id)
            elevl = nil # Escalation Level
            eleto = nil # Escalated To
            if eh.present?
              esc = EscalationMatrix.find(eh.last.esc_id)
              elevl = esc.try(:name)
              eleto = UserSociety.where(id: esc.escalate_to_users).last.try(:user_full_name)
            end

            rating = []
            if soc.feedbacks.present?
              if soc.feedbacks.last.rating == 1
                rating="Terrible"
              elsif soc.feedbacks.last.rating == 2
                rating="Bad"
              elsif soc.feedbacks.last.rating == 3
                rating="Okay"
              elsif soc.feedbacks.last.rating == 4
                rating="Good"
              elsif soc.feedbacks.last.rating == 5
                rating="Great"
              end
            end

            @selected_col_mapping = {"Id": soc.id,"Ticket ID": soc.ticket_number,"Created Date": cd,"Created Time": ct,
                                     "Complaint Title": soc.heading,"Complaint Description": soc.text,"Status": ComplaintStatus.find_by_id(soc.issue_status).try(:name) || csn || "Pending",
                                     "Category": soc.name,"Issue Type": cit,"Complaint Type": cct,"Urgency": ur,"Created By": soc.user_society.present? ? soc.user_society.user_full_name : "",
                                     "Tower": csb, "Flat": csf, "Updated Date": cst,"Updated By": csun,"Assigned To": assgnd,"Comment": cmt,
                                     "Priority": prio,"Response TAT (Min)": soc.tat,"Response TAT Breached": (@respbreached.include?(soc.id) ? "Yes" : "No"), "Resolution TAT (Min)": resotat,"Resolution TAT Breached": (@resolutionbreached.include?(soc.id) == soc.id ? "Yes" : "No"),"Response Time (Min)": resptime,
                                     "Resolution Time (Min)": resolutime,"Response Escalation Level": elevl,"Response Escalated To": eleto,"Preventive Action": soc.preventive_action,"Responsible Person Name": soc.person_id,"Mode of Complaint": soc.complaint_mode.try(:name),"Review (Tracking)": soc.review_tracking_date,"Complaint Location": (soc.tower_id.present? && soc.wing_id.present? && soc.area_id.present?) ? (soc.society_block.name << " | " << soc.wing.name << " | " << soc.area.name) : "","Agency": soc.supplier.try(:name),"Root Cause": soc.root_cause,"Proactive/Reactive": soc.proactive_reactive,
                                     "Impact": soc.impact,"Correction": soc.correction,"Corrective Action": soc.corrective_action,"Rating": rating.present? ? rating : nil,"Feedback": soc.feedbacks.present? ? soc.feedbacks.last.comment : nil }
            thisrow = []
            colomns_for_export.each do |col|
              thisrow << @selected_col_mapping[col.to_sym]
            end
            csv << thisrow
          end
        end
        send_data @formated, :filename => 'helpdesk_report.csv'
      end
    end

    def sitelist
      lup = @user.lock_user_permission
      # @sites = Pms::Site.active.where(company_id: @user.company_id)
      @sites = lup.allowed_sites
      @selected_sites = @user.selected_pms_site.pms_site
      render json: {sites: @sites , selected_site: @selected_sites}
    end

    def change_site
      @selected = @user.selected_pms_site
      if @selected.present?
        @selected.update(pms_site_id: params[:site_id])
      else
        @selected = SelectedPmsSite.new(user_id: @user.id, pms_site_id: params[:site_id])
        @selected.save!
      end
      @pms_site = @selected.pms_site
      if params["format"] == "json"
        render json: @pms_site and return
      else
        redirect_to "/pms/assets/dashboard"
      end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_complaint
      @complaint = Complaint.find_by(id: params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def complaint_params
      if params[:complaint].present?
        params.require(:complaint).permit(:id_society, :asset_id, :complaint_mode_id, :tower_id, :wing_id, :id_user, :heading, :text, :active, :action, :IsDelete, :flat_number, :issue_type, :issue_status, :category_type_id, :is_urgent, :updated_by, :user_society_id, :issue_type_id, :assigned_to, :complaint_type, :priority, :urgency, :ticket_number, :on_behalf_of, :of_phase, :site_id, :dept_id, :unit_id, :society_staff_type, :asset_id, :sub_category_id, :proactive_reactive, :root_cause, :impact, :correction, :corrective_action, :impact_details, :severity, :service_type, :solution, :workaround, :post_incident_action, :mode, :ticket_type, :group_name, :items, :emails_to_notify, :due_date_by, :response_due_date, :requester_phone, :requester_department, :requester_job, :scheduled_start_time, :scheduled_end_time, :responded_at, :closure_date, :response_time, :resolution_time, :additional_notes)
      else
        params.permit(:id_society, :tower_id, :wing_id, :asset_id, :complaint_mode_id, :id_user, :heading, :text, :active, :action, :IsDelete, :flat_number, :issue_type, :issue_status, :category_type_id, :is_urgent, :updated_by, :user_society_id, :issue_type_id, :assigned_to, :complaint_type, :priority, :urgency, :ticket_number, :on_behalf_of, :of_phase, :site_id, :dept_id, :unit_id, :society_staff_type, :asset_id, :sub_category_id, :proactive_reactive, :root_cause, :impact, :correction, :corrective_action, :impact_details, :severity, :service_type, :solution, :workaround, :post_incident_action, :mode, :ticket_type, :group_name, :items, :emails_to_notify, :due_date_by, :response_due_date, :requester_phone, :requester_department, :requester_job, :scheduled_start_time, :scheduled_end_time, :responded_at, :closure_date, :response_time, :resolution_time, :additional_notes)
      end
    end

  end
end
