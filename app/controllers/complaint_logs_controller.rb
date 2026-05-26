class ComplaintLogsController < ApplicationController
  include UserExt
  before_action :authenticate_user!, if: :check_user
  #load_and_authorize_resource if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_complaint_log, only: [:show, :edit, :update, :destroy]

  # GET /complaint_logs
  # GET /complaint_logs.json
  def index
    @complaint_logs = ComplaintLog.where(complaint_id: params[:complaint_id])
  end

  # GET /complaint_logs/1
  # GET /complaint_logs/1.json
  def show
  end

  # GET /complaint_logs/new
  def new
    @complaint_log = ComplaintLog.new
  end

  # GET /complaint_logs/1/edit
  def edit
  end

  def reopen
    if params[:of_phase] == "pms"
      @complaint_status_id = ComplaintStatus.active.where(of_phase: "pms",society_id: params[:complaint_log][:soc_id]).find_by(fixed_state: "reopen").try(:id)
    else
      @complaint_status_id = ComplaintStatus.active.where(society_id: @curusoc.id_society).find_by(fixed_state: "reopen").try(:id)
    end
    @complaint_log = ComplaintLog.new(complaint_log_params.merge(:changed_by => @user.id, :complaint_status_id => @complaint_status_id))
    respond_to do |format|
      if @complaint_log.save
        if params[:complaint_log][:comment].present? 
          @complaint_comment = ComplaintComment.create(comment: params[:complaint_log][:comment], complaint_id: @complaint_log.complaint_id, changed_by: @user.id, complaint_log_id:@complaint_log.id, active: 1)
        end
        format.html { redirect_to params[:custom_redirect].present? ? params[:custom_redirect] : "/crm/complaints/#{@complaint_log.complaint_id}/"}
        format.json { render json: @complaint_log, status: 200}
      else
        format.html { redirect_to params[:custom_redirect].present? ? params[:custom_redirect] : "/crm/complaints/#{@complaint_log.complaint_id}/" , alert: @complaint_log.errors.full_messages.join(",")}
        format.json { render json: {message: @complaint_log.errors.full_messages.join(",")}, status: :unprocessable_entity  }
      end
    end
  end

  # POST /complaint_logs
  # POST /complaint_logs.json
  def create
    @complaint_log = ComplaintLog.new(complaint_log_params)
    @complaint_log.changed_by = @user.id
    @complaint_log.update_params = params
    @complaint = Complaint.find_by(id: @complaint_log.complaint_id)

    respond_to do |format|
      complaint_log_not_changed = @complaint_log.check_last_log
      if params[:complaint].present?
        if params[:complaint][:review_tracking_date].present?
          review_tracking_date = params[:complaint][:review_tracking_date].to_date
        end
        assigned_user_id = params[:complaint][:assigned_to] || params[:complaint_log][:assigned_to]

        if assigned_user_id.present? && !User.exists?(assigned_user_id)
          format.json { render json: { error: "Assigned user not found" }, status: :unprocessable_entity } and return
        end

        @complaint.update(issue_status: params[:complaint][:issue_status_id], complaint_type: params[:complaint][:complaint_type],reference_number: params[:complaint][:reference_number],urgency: params[:complaint][:urgency], preventive_action: params[:complaint][:preventive_action],person_id: params[:complaint][:person_id],priority: params[:complaint][:priority] || params[:complaint_log][:priority],category_type_id: params[:complaint][:category_type_id] || params[:complaint_log][:category_type_id],sub_category_id: params[:complaint][:sub_category_id] || params[:complaint_log][:sub_category_id],assigned_to: assigned_user_id ,complaint_mode_id: params[:complaint][:complaint_mode_id],review_tracking_date: review_tracking_date,society_location_id: params[:complaint][:society_location_id],wing_id: params[:complaint][:wing_id],area_id: params[:complaint][:area_id],supplier_id: params[:complaint][:supplier_id],root_cause: params[:complaint][:root_cause],proactive_reactive: params[:complaint][:proactive_reactive],impact: params[:complaint][:impact],correction: params[:complaint][:correction],corrective_action: params[:complaint][:corrective_action],issue_related_to: params[:complaint][:issue_related_to],severity: params[:complaint][:severity],service_type: params[:complaint][:service_type],external_priority: params[:complaint][:external_priority],project_email: params[:complaint][:project_email],additional_notes: params[:complaint][:additional_notes],asset_id: params[:asset_id], service_id: params[:service_id])
        @complaint.update(urgency: params[:complaint][:urgency]) if params[:complaint][:urgency].present?
        @complaint.update(territory_manager_id: params[:complaint][:territory_manager_id]) if params[:complaint][:territory_manager_id].present?
        flash_msg='Complaint was successfully updated.'
        @complaint.update_attributes(complaint_cost_requests_params) if params[:complaint][:cost_involved].present?
      end
      @complaint_log.update_params = @complaint.try(:current_changes)
      if @complaint.saved_change_to_issue_related_to?
        @complaint_log.issue_related_to = @complaint.issue_related_to
      end
      if @complaint.saved_change_to_category_type_id?
        @complaint_log.helpdesk_category_id = @complaint.category_type_id
      end
      if @complaint_log.priority.present? || @complaint_log.complaint_status_id.present? || @complaint_log.assigned_to.present? || params[:complaint_log][:internal_comment].present? || params[:complaint_log][:comment].present? || @complaint_log.update_params.present?
          if @complaint_log.save
            flash_msg='Complaint log was successfully created.'
            @complaint.update(priority: @complaint_log.priority) if @complaint_log.priority.present?
            @complaint.update(assigned_to: @complaint_log.assigned_to, society_staff_type: @complaint_log.society_staff_type) if @complaint_log.assigned_to.present?
            if @complaint_log.complaint_status.present? && @complaint_log.complaint_status.fixed_state == "closed"
              @complaint.update(closure_date: DateTime.now) 
            elsif @complaint_log.complaint_status.present? && @complaint_log.complaint_status != "closed"
              @complaint.update(closure_date: nil)   
            end  
            if params[:complaint_log][:comment].present? && @complaint_log.present?
             @complaint_comment = ComplaintComment.create(comment: params[:complaint_log][:comment],complaint_id: @complaint_log.complaint_id, changed_by: @user.id, complaint_log_id:@complaint_log.id, active: 1)       
              @complaint_comment.save
              flash_msg='Complaint comment was successfully created.'        
              
              # Handle file uploads for complaint_comment
              if params[:complaint_comment].present? && params[:complaint_comment][:docs].present?
                params[:complaint_comment][:docs].each do |doc|
                  begin
                    if doc.is_a?(ActionDispatch::Http::UploadedFile)
                      # Direct upload without createimage
                      Attachfile.create(image: doc, relation: "ComplaintComment", relation_id: @complaint_comment.id, active: 1)
                    else
                      # Base64 encoded image
                      file_path = Attachfile.createimage(doc)
                      Attachfile.create(image: File.new(file_path, 'r'), relation: "ComplaintComment", relation_id: @complaint_comment.id, active: 1)
                    end
                  rescue => e
                    Rails.logger.error "Error saving attachment: #{e.message}"
                  end
                end
              end
              
              if params[:complaint_comment].present? && params[:complaint_comment][:doc].present?
                begin
                  if params[:complaint_comment][:doc].is_a?(ActionDispatch::Http::UploadedFile)
                    Attachfile.create(image: params[:complaint_comment][:doc], relation: "ComplaintComment", relation_id: @complaint_comment.id, active: 1)
                  else
                    file_path = Attachfile.createimage(params[:complaint_comment][:doc])
                    Attachfile.create(image: File.new(file_path, 'r'), relation: "ComplaintComment", relation_id: @complaint_comment.id, active: 1)
                  end
                rescue => e
                  Rails.logger.error "Error saving attachment: #{e.message}"
                end
              end

              if params[:complaint_comment].present? && params[:complaint_comment][:attachments].present? 
                params[:complaint_comment][:attachments].each do |doc|
                  begin
                    Attachfile.create(image: doc, relation: "ComplaintComment", relation_id: @complaint_comment.id, active: 1)
                  rescue => e
                    Rails.logger.error "Error saving attachment: #{e.message}"
                  end
                end
               end
            end

            if params[:complaint_log][:internal_comment].present? && @complaint_log.present?
             @complaint_internal_comment = InternalComplaintComment.create(comment: params[:complaint_log][:internal_comment],changed_by: @user.id, complaint_log_id:@complaint_log.id)       
              @complaint_internal_comment.save
              flash_msg='Complaint comment was successfully created.'        
              if params[:internal_complaint_comment][:docs].present?
                params[:internal_complaint_comment][:docs].each do |doc|
                 file_path = Attachfile.createimage(doc)
                 Attachfile.create(image: File.new(file_path, 'r'), relation: "InternalComplaintComment", relation_id: @complaint_internal_comment.id, active: 1)
                end
              end
              
            end
          format.html { redirect_to params[:save_and_show_detail] ? (params[:custom_redirect] || @complaint_log) : params[:custom_redirect]  , notice: flash_msg}
          format.json { render "pms/manage/complaints/show", status: :created, location: @complaint_log }
        else
          format.html { redirect_to "/pms/complaints/#{@complaint.id}/complaint_edit_form" , alert: @complaint_log.errors.full_messages.join(",")}
          format.json { render json: {message: @complaint_log.errors.full_messages.join(",")}, status: :unprocessable_entity  }
        end
       
      else
        puts @complaint_log.errors.full_messages
        format.html { redirect_to params[:custom_redirect],notice: flash_msg }
        format.json { render json: @complaint_log.errors }
      end
    end
  end

  # PATCH/PUT /complaint_logs/1
  # PATCH/PUT /complaint_logs/1.json
  def update
    respond_to do |format|
      if @complaint_log.update(complaint_log_params)
        format.html { redirect_to @complaint_log, notice: 'Complaint log was successfully updated.' }
        format.json { render :show, status: :ok, location: @complaint_log }
      else
        format.html { render :edit }
        format.json { render json: @complaint_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /complaint_logs/1
  # DELETE /complaint_logs/1.json
  def destroy
    @complaint_log.destroy
    respond_to do |format|
      format.html { redirect_to complaint_logs_url, notice: 'Complaint log was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def update_complaint_logs
    
    response = { :status => false, :message => "Unable to update" }
    
    complaint = Complaint.where(id: params[:complaint_log_ids])
    
     if complaint.length > 0 && 
      params[:issue_status].present? ||
      params[:external_priority].present? ||
      params[:complaint_mode_id].present? ||
      params[:priority].present? ||
      params[:assigned_to].present?
     

      complaint.each do |comp|
          
          columns = {:complaint_id => comp.id, changed_by: @user.id}
          comps = {}

          if params[:issue_status].present?
            columns[:complaint_status_id] = params[:issue_status] 
          end
          
          if params[:priority].present?
            comps[:priority] = params[:priority] 
          end
          
          if params[:external_priority].present?
            comps[:external_priority] = params[:external_priority] 
          end

          if params[:assigned_to].present?
            comps[:assigned_to] = params[:assigned_to] 
          end

          if params[:complaint_mode_id].present?
            # columns[:complaint_mode_id] = params[:complaint_mode_id] 
            comps[:complaint_mode_id] = params[:complaint_mode_id] 
          end


        com_log = ComplaintLog.create(columns)
        comp_update = comp.update(comps)
      end

      response = { :status => true, :message => "updated successfully" }

    end

    respond_to do |format|
      format.json  { render :json => response }
    end

  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_complaint_log
      @complaint_log = ComplaintLog.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def complaint_log_params
      params.require(:complaint_log).permit(:complaint_id, :complaint_status_id, :category_type_id, :changed_by, :priority, :sub_category_id, :issue_related_to, :update_params, :comment)
    end

    def complaint_params
      if params[:complaint].present?
        params.require(:complaint).permit(:id_society, :id_user, :heading, :text, :active, :action, :IsDelete, :flat_number, :issue_type_id, :society_staff_type, :category_type_id, :is_urgent, :updated_by, :user_society_id, :issue_type_id, :assigned_to, :complaint_type, :priority,:external_priority, :urgency, :ticket_number, :of_phase, :client_society_id, :territory_manager_id, :attachments_attributes => [:id, :image, :relation, :relation_id, :active])
      else
        params.permit(:id_society, :id_user, :heading, :text, :active, :action, :IsDelete, :flat_number, :issue_type_id, :category_type_id, :society_staff_type, :is_urgent, :updated_by, :user_society_id, :issue_type_id, :assigned_to, :complaint_type, :priority,:external_priority, :urgency, :ticket_number, :of_phase, :client_society_id, :territory_manager_id, :attachments_attributes => [:id, :image, :relation, :relation_id, :active])
      end
    end

    def complaint_cost_requests_params
      params.require(:complaint).permit(:id, :cost_involved,
        cost_approval_requests_attributes: [:id, :cost, :active, :created_by_id, :comment, :attachments_attributes => [:id, :image, :relation, :relation_id, :active]]
      )
    end

end