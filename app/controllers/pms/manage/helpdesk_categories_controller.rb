module Pms
  module Manage
    class HelpdeskCategoriesController < ApplicationController
      include UserExt
      layout 'basic'
      before_action :authenticate_user!, if: :check_user, except: :web_view_reports
      before_action :api_user, except: :web_view_reports
      before_action :set_user, except: :web_view_reports
      before_action :set_helpdesk_category, only: [:show, :edit, :update, :destroy]
      # GET /helpdesk_categories
      # GET /helpdesk_categories.json
      def index
        @page_name = "Helpdesk Setup"
        @helpdesk_categories = HelpdeskCategory.active.where(society_id: @user.current_site_id).search(params[:q]).result.order(created_at: :desc)
        @helpdesk_sub_categories = HelpdeskSubCategory.active.where(helpdesk_category_id: @helpdesk_categories.pluck(:id))
        @statuses = ComplaintStatus.active.where(society_id: @user.current_site_id).order(:position).sort_by(&:name)
        @complaint_modes = ComplaintMode.active.where(society_id: @user.current_site_id)
        @complaint_worker = ComplaintWorker.active.where(society_id: @user.current_site_id).ransack(params[:q]).result
        @active_complaint_workers = ComplaintWorker.where(site_id: @user.current_site_id, assign: '1')
      end

      # GET /helpdesk_categories/1
      # GET /helpdesk_categories/1.json
      def show
        respond_to do |format|
          format.html # This will use the default show.html.erb template
          format.json { render json: @helpdesk_category.to_json(include: :helpdesk_sub_categories) }
        end
      end

      # GET /helpdesk_categories/new
      def new
        @helpdesk_category = HelpdeskCategory.new
      end

      # GET /helpdesk_categories/1/edit
      def edit
      end

      # POST /helpdesk_categories
      # POST /helpdesk_categories.json
      def create
        @helpdesk_category = HelpdeskCategory.new(helpdesk_category_params)
        @helpdesk_category.response_tat = params[:response_tat].present? ? params[:response_tat].to_json : "{}"
        respond_to do |format|
          if @helpdesk_category.save
            if params[:attachfiles].present?
              params[:attachfiles].each do |doc|
                Attachfile.create(image: doc, relation: "HelpdeskCategoryIcon", relation_id: @helpdesk_category.id, active: 1)
              end
            end
            if params[:complaint_worker].present? && params[:complaint_worker][:assign_to].present?
              if ComplaintWorker.pms.where(category_id: @helpdesk_category.id).applicable_cw_for(@user.current_site_id, @user.selected_site_id).present?
                ComplaintWorker.pms.where(category_id: @helpdesk_category.id).applicable_cw_for(@user.current_site_id, @user.selected_site_id).update(site_id: @user.selected_site_id, assign_to: params[:complaint_worker][:assign_to])
              else
                ComplaintWorker.create(site_id: @user.selected_site_id, society_id: @helpdesk_category.society_id, issue_type_id: nil, category_id: @helpdesk_category.id, assign_to: params[:complaint_worker][:assign_to], esc_type: nil, of_phase: "pms", of_atype: "Society")
              end
            end
            if params[:category_email].present? && params[:category_email][:email].present?
              @email = params[:category_email][:email].split(/,\s*/)
              @email.each do |e|
                @helpdesk_cat_email = CategoryEmail.new(site_id: @user.try(:selected_pms_site).try(:pms_site).try(:id), cat_id: @helpdesk_category.id, email: e)
                @helpdesk_cat_email.save
              end
            end
            format.html { redirect_to params[:helpdesk_category][:custom_redirect] || manage_helpdesk_category(@helpdesk_category), notice: 'Helpdesk category was successfully created.' }
            format.json { render json: @helpdesk_category, status: :created }
          else
            format.html { redirect_to params[:helpdesk_category][:custom_redirect], alert: @helpdesk_category.errors.full_messages.join(" , ") }
            format.json { render json: @helpdesk_category.errors, status: :unprocessable_entity }
          end
        end
      end

      def create_helpdesk_sub_category
        @helpdesk_sub_category = HelpdeskSubCategory.new(helpdesk_sub_category_params)
        respond_to do |format|
          if params[:sub_category_tags].respond_to?(:join) && params[:sub_category_tags].join.present?
            sub_category_tags = params[:sub_category_tags][0].split(",")
            sub_category_tags.each do |sub_category|
              HelpdeskSubCategory.create(helpdesk_category_id: params[:helpdesk_sub_category][:helpdesk_category_id],name: sub_category,issue_type_id: params[:helpdesk_sub_category][:issue_type_id])
            end
            format.html { redirect_to params[:helpdesk_sub_category][:custom_redirect] || manage_helpdesk_category(@helpdesk_sub_category), notice: 'Helpdesk sub-category was successfully created.' }
            format.json { render json: @helpdesk_sub_category, status: :created }
          elsif @helpdesk_sub_category.save
            format.html { redirect_to params[:helpdesk_sub_category][:custom_redirect] || manage_helpdesk_category(@helpdesk_sub_category), notice: 'Helpdesk sub-category was successfully created.' }
            format.json { render json: @helpdesk_sub_category, status: :created }
          else
            format.html { redirect_to params[:helpdesk_sub_category][:custom_redirect] || manage_helpdesk_category(@helpdesk_sub_category), alert: 'Please enter sub category' }
            format.json { render json: @helpdesk_sub_category.errors, status: :unprocessable_entity }
          end
        end
      end

      def modify_helpdesk_sub_category
        @helpdesk_sub_category = HelpdeskSubCategory.find(params[:id])
        @helpdesk_sub_category.update(name: params[:name],helpdesk_category_id: params[:helpdesk_category_id],active: params[:active])
        respond_to do |format|
          format.html { redirect_to params[:custom_redirect], notice: "Sub Category was Successfully updated"}
          format.json { render json: @helpdesk_sub_category }
        end
      end

      def helpdesk_reports_api
        # byebug
        if params[:spree_token].present? && params[:society_id].present?
          if params[:spree_token] == @user.api_key &&  params[:society_id] == @curusoc.id_society
            ntctxt = "Success"
            redirect_to api_helpdesk_reports_path , notice: ntctxt
          else
            ntctxt = "You are not authorised to open this url."
            redirect_to api_helpdesk_reports_path , danger: ntctxt
          end
        end
      end

      def create_issue_type
        @issue_types = IssueType.where(society_id: params[:society_id], name: params[:name])
        if @issue_types.present?
          @issue_type = @issue_types.last
          @issue_type.update(society_id: params[:society_id], name: params[:name], active: 1)
        else
          @issue_type = IssueType.new(society_id: params[:society_id], name: params[:name], active: 1)
        end
        respond_to do |format|
          if @issue_type.save
            format.html { redirect_to params[:custom_redirect], notice: @issue_type.errors.full_messages.join(" , ")}
            format.json { render json: @issue_type and return }
          end
        end
      end

      def clone_escalations
        cookies[:hdtabs] = "escalation"
        cw = ComplaintWorker.find(params[:cw_id])
        cw.clone_escalations(params[:region_ids], params[:zone_ids], @user.id) if cw.present?
        respond_to do |format|
          format.html { redirect_to "/pms/admin/helpdesk_categories", notice: "Successfully Cloned Data" }
        end
      end

      def modify_issue_type
        @issue_type = IssueType.find(params[:id])
        @issue_type.update(name: params[:name], active: params[:active])
        respond_to do |format|
          format.html { redirect_to params[:custom_redirect], notice: @issue_type.errors.full_messages.join(" , ")}
          format.json { render json: @issue_type }
        end
      end
      def complaint_assign
        @con = SystemConstant.find_by(name: params[:system_constant][:name])
        if !@con.present?
          @con = SystemConstant.new(name: params[:system_constant][:name])
        end
        @con.value = params[:system_constant][:value]
        @con.save
        respond_to do |format|
          format.html { redirect_to params[:custom_redirect]}
          format.json { render json: @issue_type }
        end
      end

      def modify_complaint_status
        @complaint_status = ComplaintStatus.find(params[:id])
        respond_to do |format|
          format.json do
            if params[:active].present? && params[:active].to_i == 0
              @complaint_status.update_column(:active, 0)
              render json: { message: "Status Deleted Successfully" }
            elsif @complaint_status.update(
              name: params[:name].to_s.downcase.titleize.squeeze(" "),
              color_code: params[:color_code],
              position: params[:position],
              active: params[:active],
              fixed_state: params[:fixed_state]
            )
              render json: { message: "Status Updated Successfully" }
            else
              render json: { error: @complaint_status.errors.full_messages.join(", ") }, status: :unprocessable_entity
            end
          end
          format.html do
            if params[:active].present? && params[:active].to_i == 0
              @complaint_status.update_column(:active, 0)
              redirect_to "/pms/admin/helpdesk_categories", notice: "Status Deleted Successfully"
            elsif @complaint_status.update(
              name: params[:name].to_s.downcase.titleize.squeeze(" "),
              color_code: params[:color_code],
              position: params[:position],
              active: params[:active],
              fixed_state: params[:fixed_state]
            )
              redirect_to "/pms/admin/helpdesk_categories", notice: "Status Updated Successfully"
            else
              redirect_to "/pms/admin/helpdesk_categories", alert: @complaint_status.errors.full_messages.join(", ")
            end
          end
        end
      end

      def create_escalation
        # Initialize the model with nested parameters
        @escalation_matrix = EscalationMatrix.new(escalation_params[:escalation_matrix])

        respond_to do |format|
          if @escalation_matrix.save
            format.html { redirect_to params[:escalation_matrix][:custom_redirect], notice: 'Escalation successfully created.' }
            format.json { render :show, status: :created, location: @escalation_matrix }
          else
            format.html { render :new }
            format.json { render json: @escalation_matrix.errors, status: :unprocessable_entity }
          end
        end
      end


      def create_complaint_statuses
        @complaint_status = ComplaintStatus.new(complaint_status_params.merge(active: 1))

        @complaint_status.name = params[:complaint_status][:name].downcase.titleize.squeeze(" ")
        if params[:complaint_status][:of_phase].blank?
          params[:complaint_status][:of_phase] = "pms"
        end

        @complaint_statuses = ComplaintStatus.active.where(society_id: @user.current_site_id, of_phase: params[:complaint_status][:of_phase])
        @complaint_status_name = @complaint_statuses.pluck(:name)
        @complaint_status_position = @complaint_statuses.pluck(:position)

        name_exist = @complaint_status_name.include?(@complaint_status.name.downcase.titleize)
        position_exist = @complaint_status_position.include?(@complaint_status.position)

        respond_to do |format|
          if name_exist || position_exist
            format.html { redirect_to params[:complaint_status][:custom_redirect], danger: 'Status Or Order Already Exists' }
            format.json { render json: { error: 'Status Or Order Already Exists' }, status: :unprocessable_entity }
          else
            if @complaint_status.save
              format.html { redirect_to params[:complaint_status][:custom_redirect], notice: 'Status Created' }
              format.json { render json: @complaint_status, status: :created }
            else
              format.html { redirect_to params[:complaint_status][:custom_redirect], alert: 'Status Creation Failed' }
              format.json { render json: @complaint_status.errors, status: :unprocessable_entity }
            end
          end
        end
      end


      def complaint_statuses
        if params[:id].present?
          @complaint_status = ComplaintStatus.find_by(id: params[:id])
          if @complaint_status.nil?
            render json: { error: 'ComplaintStatus not found' }, status: :not_found
            return
          end
        else
          @complaint_statuses = ComplaintStatus.where(society_id: @user.current_site_id)
        end

        respond_to do |format|
          format.json { render :complaint_statuses }
        end
      end

      def update_complaint_statuses
        @complaint_status = ComplaintStatus.find(params[:id])

        updated_name = params[:complaint_status][:name].downcase.titleize.squeeze(" ")

        if params[:complaint_status][:of_phase].blank?
          params[:complaint_status][:of_phase] = "pms"
        end

        @complaint_statuses = ComplaintStatus.active
        .where(
          society_id: @user.current_site_id,
          of_phase: params[:complaint_status][:of_phase]
        )
        .where.not(id: @complaint_status.id)

        name_exist = @complaint_statuses.pluck(:name).map(&:downcase).include?(updated_name.downcase)

        position_exist = @complaint_statuses.pluck(:position)
        .include?(params[:complaint_status][:position].to_i)

        respond_to do |format|
          if name_exist || position_exist
            format.html do
              redirect_to params[:complaint_status][:custom_redirect],
                danger: 'Status Or Order Already Exists'
            end

            format.json do
              render json: { error: 'Status Or Order Already Exists' },
                status: :unprocessable_entity
            end
          else
            if @complaint_status.update(
                complaint_status_params.merge(
                  name: updated_name
                )
              )

              format.html do
                redirect_to params[:complaint_status][:custom_redirect],
                  notice: 'Status Updated'
              end

              format.json do
                render json: @complaint_status,
                  status: :ok
              end
            else
              format.html do
                redirect_to params[:complaint_status][:custom_redirect],
                  alert: 'Status Update Failed'
              end

              format.json do
                render json: @complaint_status.errors,
                  status: :unprocessable_entity
              end
            end
          end
        end
      end



      def create_complaint_modes
        @complaint_mode = ComplaintMode.new(complaint_mode_params)
        respond_to do |format|
          if @complaint_mode.save
            format.html { redirect_to params[:custom_redirect] , notice: 'Complaint Mode saved Successfully'}
          else
            format.html { redirect_to params[:custom_redirect] , danger: @complaint_mode.errors.full_messages.join(" , ")}
          end
        end
      end

      def update_complaint_mode
        @complaint_mode = ComplaintMode.find(params[:id])
        @complaint_mode.update(complaint_mode_params)
        redirect_to "/pms/admin/helpdesk_categories" , notice: 'Complaint Mode Updated Successfully'
      end

      def delete_complaint_mode
        cm = ComplaintMode.find(params[:id])
        cm.update(active: 0)
        redirect_to "/pms/admin/helpdesk_categories" , notice: 'Complaint Mode Deleted Successfully'
      end

      def create_society_location
        # byebug
        @society_location = SocietyLocation.new(society_location_params)
        respond_to do |format|
          if @society_location.save
            format.html { redirect_to params[:custom_redirect] , notice: 'Level 1 saved Successfully'}
          else
            format.html { redirect_to params[:custom_redirect] , danger: @society_location.errors.full_messages.join(" , ")}
          end
        end
      end

      def delete_society_location
        society_location = SocietyLocation.find(params[:id])
        society_location.update(active: 0)
        redirect_to params[:custom_redirect] , notice: 'Level 1 Deleted Successfully'
      end

      def create_pms_wing
        # byebug
        @pms_wing = Pms::Wing.new(pms_wing_params)
        respond_to do |format|
          if @pms_wing.save
            format.html { redirect_to params[:custom_redirect] , notice: 'Level 2 saved Successfully'}
          else
            format.html { redirect_to params[:custom_redirect] , danger: @pms_wing.errors.full_messages.join(" , ")}
          end
        end
      end

      def delete_pms_wing
        pms_wing = Pms::Wing.find(params[:id])
        pms_wing.update(active: 0)
        redirect_to params[:custom_redirect] , notice: 'Level 2 Deleted Successfully'
      end

      def create_pms_area
        # byebug
        @pms_area = Pms::Area.new(user_id: params[:user_id],society_id: @curusoc.id_society,society_location_id: params[:pms_area][:society_location_id],wing_id: params[:pms_area][:wing_id],name: params[:pms_area][:name])
        respond_to do |format|
          if @pms_area.save
            format.html { redirect_to params[:custom_redirect] , notice: 'Level 3 saved Successfully'}
          else
            format.html { redirect_to params[:custom_redirect] , danger: @pms_area.errors.full_messages.join(" , ")}
          end
        end
      end

      def delete_pms_area
        pms_area = Pms::Area.find(params[:id])
        pms_area.update(active: 0)
        redirect_to params[:custom_redirect] , notice: 'Level 3 Deleted Successfully'
      end

      def create_pms_supplier
        # byebug
        @pms_supplier = Pms::Supplier.new(pms_supplier_params)
        respond_to do |format|
          if @pms_supplier.save
            format.html { redirect_to params[:custom_redirect] , notice: 'Vendor saved Successfully'}
          else
            format.html { redirect_to params[:custom_redirect] , danger: 'Error Occured while saving Vendor'}
          end
        end
      end

      def show_vendor_details
        @pms_supplier = Pms::Supplier.find(params[:format])
      end

      def delete_complaint_worker
        cw = ComplaintWorker.find(params[:id])
        respond_to do |format|
          if cw.destroy
            format.html { redirect_to params[:custom_redirect], notice: 'Successfully deleted.' }
            format.json { render json: { notice: 'Successfully deleted.' }, status: :ok }
          else
            format.html { redirect_to params[:custom_redirect], alert: cw.errors.full_messages.join(", ") }
            format.json { render json: { errors: cw.errors.full_messages }, status: :unprocessable_entity }
          end
        end
      end



      def clone_to_resolution
        cookies[:hdtabs] = "escalation"
        my_post = ComplaintWorker.find(params[:cw_id])
        new_post = my_post.amoeba_dup
        new_post.esc_type = "resolution"
        new_post.save
        redirect_to "/pms/admin/helpdesk_categories"
      end

      def update_complaint_worker
        cw = ComplaintWorker.find(params[:id])
        cw.update(complaint_worker_params)
        csi = 1 #params[:escalation_matrix][:complaint_status_id]
        if params[:escalation_matrix].present?
          esc1 = params[:escalation_matrix][:e1] || {}
          # if esc1[:p1].present? || esc1[:p2].present? || esc1[:p3].present?
          escm = cw.escalations.find_by(name: "E1")
          if !escm.present?
            escm = EscalationMatrix.new(cw_id: cw.id, name: esc1[:name], p1: esc1[:p1], p2: esc1[:p2], p3: esc1[:p3], p4: esc1[:p4], p5: esc1[:p5], escalate_to_users: esc1[:escalate_to_users])
            escm.save
          else
            escm.update(p1: esc1[:p1], p2: esc1[:p2], p3: esc1[:p3], p4: esc1[:p4], p5: esc1[:p5], escalate_to_users: esc1[:escalate_to_users])
          end
          # end

          esc1 = params[:escalation_matrix][:e2] || {}
          # if esc1[:p1].present? || esc1[:p2].present? || esc1[:p3].present?
          escm = cw.escalations.find_by(name: "E2")
          if !escm.present?
            escm = EscalationMatrix.new(cw_id: cw.id, name: esc1[:name], p1: esc1[:p1], p2: esc1[:p2], p3: esc1[:p3], p4: esc1[:p4], p5: esc1[:p5], escalate_to_users: esc1[:escalate_to_users])
            escm.save
          else
            escm.update(p1: esc1[:p1], p2: esc1[:p2], p3: esc1[:p3], p4: esc1[:p4], p5: esc1[:p5], escalate_to_users: esc1[:escalate_to_users])
          end
          # end

          esc1 = params[:escalation_matrix][:e3] || {}
          # if esc1[:p1].present? || esc1[:p2].present? || esc1[:p3].present?
          escm = cw.escalations.find_by(name: "E3")
          if !escm.present?
            escm = EscalationMatrix.new(cw_id: cw.id, name: esc1[:name], p1: esc1[:p1], p2: esc1[:p2], p3: esc1[:p3], p4: esc1[:p4], p5: esc1[:p5], escalate_to_users: esc1[:escalate_to_users])
            escm.save
          else
            escm.update(p1: esc1[:p1], p2: esc1[:p2], p3: esc1[:p3], p4: esc1[:p4], p5: esc1[:p5], escalate_to_users: esc1[:escalate_to_users])
          end
          # end

          esc1 = params[:escalation_matrix][:e4] || {}
          # if esc1[:p1].present? || esc1[:p2].present? || esc1[:p3].present?
          escm = cw.escalations.find_by(name: "E4")
          if !escm.present?
            escm = EscalationMatrix.new(cw_id: cw.id, name: esc1[:name], p1: esc1[:p1], p2: esc1[:p2], p3: esc1[:p3], p4: esc1[:p4], p5: esc1[:p5], escalate_to_users: esc1[:escalate_to_users])
            escm.save
          else
            escm.update(p1: esc1[:p1], p2: esc1[:p2], p3: esc1[:p3], p4: esc1[:p4], p5: esc1[:p5], escalate_to_users: esc1[:escalate_to_users])
          end
          # end

          esc1 = params[:escalation_matrix][:e5] || {}
          # if esc1[:p1].present? || esc1[:p2].present? || esc1[:p3].present?
          escm = cw.escalations.find_by(name: "E5")
          if !escm.present?
            escm = EscalationMatrix.new(cw_id: cw.id, name: esc1[:name], p1: esc1[:p1], p2: esc1[:p2], p3: esc1[:p3], p4: esc1[:p4], p5: esc1[:p5], escalate_to_users: esc1[:escalate_to_users])
            escm.save
          else
            escm.update(p1: esc1[:p1], p2: esc1[:p2], p3: esc1[:p3], p4: esc1[:p4], p5: esc1[:p5], escalate_to_users: esc1[:escalate_to_users])
          end
          # end
        end
        redirect_to params[:custom_redirect]
      end



      def create_complaint_worker
        fnotice = ""
        if params[:category_ids].present?
          params[:category_ids].each do |cat_id|
            ComplaintWorker.transaction do
              # Delete existing complaint workers with the same escalation type for this category and site
              ComplaintWorker.where(
                category_id: cat_id,
                site_id: @user.current_site_id,
                esc_type: complaint_worker_params[:esc_type]
              ).destroy_all

              # Create the new complaint worker
              @complaint_worker = ComplaintWorker.create!(
                complaint_worker_params.merge(
                  category_id: cat_id,
                  society_id: @user.current_site_id,
                  site_id: @user.current_site_id,
                  assign: '1'
                )
              )

              fnotice = "Successfully saved"

              if params[:escalation_matrix].present?
                cw = @complaint_worker
                %w[e1 e2 e3 e4 e5].each do |level|
                  data = params[:escalation_matrix][level] || {}
                  next unless data[:p1].present? || data[:p5].present?
                  EscalationMatrix.create(
                    cw_id: cw.id, name: data[:name],
                    p1: data[:p1], p2: data[:p2], p3: data[:p3], p4: data[:p4], p5: data[:p5],
                    escalate_to_users: data[:escalate_to_users]
                  )
                end
              end
            end
          end
        else
          @complaint_worker = ComplaintWorker.new
        end
        respond_to do |format|
          if fnotice.present?
            format.html { redirect_to params[:custom_redirect], notice: fnotice}
            format.json { render json: { notice: fnotice }, status: :created }
          else
            format.html { redirect_to params[:custom_redirect], alert: @complaint_worker.errors.full_messages.join(" , ")}
            format.json { render json: { errors: @complaint_worker.errors.full_messages }, status: :unprocessable_entity }
          end
        end
      end


      def complaint_workers
        if params[:id].present?
          @complaint_worker = ComplaintWorker.find(params[:id])
        else
          @complaint_workers = ComplaintWorker.active.ransack(params[:q]).result.order(created_at: :desc)
          @complaint_workers = @complaint_workers.pms if params[:pms].present?
          @complaint_workers = @complaint_workers.where(society_id: params[:society_id]) if params[:society_id].present?
          @complaint_workers = @complaint_workers.where(category_id: params[:category_id]) if params[:category_id].present?
        end
        respond_to do |format|
          format.json
        end
      end

      def escalations
        if params[:id].present?
          @escalation = @worker.escalations.find(params[:id])
        else
          @escalations = EscalationMatrix.where(society_id: @user.current_site_id)
        end
        respond_to do |format|
          format.json { render json: @escalation }
        end
      end



      # PATCH/PUT /helpdesk_categories/1.json
      def update
        @helpdesk_category = HelpdeskCategory.find(params[:id])
        respond_to do |format|
          if params[:complaint_worker].present? && params[:complaint_worker][:assign_to].present?
            if ComplaintWorker.pms.where(category_id: @helpdesk_category.id).applicable_cw_for(@user.current_site_id, @user.selected_site_id).present?
              ComplaintWorker.pms.where(category_id: @helpdesk_category.id).applicable_cw_for(@user.current_site_id, @user.selected_site_id).update(site_id: @user.selected_site_id, assign_to: params[:complaint_worker][:assign_to])
            else
              ComplaintWorker.create(site_id: @user.selected_site_id, society_id: @helpdesk_category.society_id, issue_type_id: nil, category_id: @helpdesk_category.id, assign_to: params[:complaint_worker][:assign_to], esc_type: nil, of_phase: "pms", of_atype: "Society")
            end
          end
          if params[:category_email].present? && params[:category_email][:email].present?
            @email = params[:category_email][:email].split(/,\s*/)
            @old_cat_email = @helpdesk_category.category_emails.pluck(:email)
            @latest_emails = @email - @old_cat_email
            @remove_emails = @old_cat_email - @email
            if @remove_emails.present?
              CategoryEmail.where("email In (?) and site_id = (?)",@remove_emails,@user.try(:selected_pms_site).try(:pms_site).try(:id)).delete_all
            end
            if @latest_emails.present?
              @latest_emails.each do |e|
                @helpdesk_cat_email = CategoryEmail.new(site_id: @user.try(:selected_pms_site).try(:pms_site).try(:id), cat_id: @helpdesk_category.id, email: e)
                @helpdesk_cat_email.save
              end
            end
          end
          if @helpdesk_category.update(helpdesk_category_params)
            if params[:attachfiles].present?
              params[:attachfiles].each do |doc|
                Attachfile.create(image: doc, relation: "HelpdeskCategoryIcon", relation_id: @helpdesk_category.id, active: 1)
              end
            end
            @helpdesk_category.update(response_tat: params[:response_tat].present? ? params[:response_tat].to_json : "{}")
            #@helpdesk_category.update(helpdesk_category_params)
            format.html { redirect_to params[:custom_redirect], notice: 'Helpdesk category was successfully updated.' }
            format.json { render json: @helpdesk_category, status: :ok}
          elsif params[:helpdesk_category][:active].present? && params[:helpdesk_category][:active].to_i == 0
            @helpdesk_category.update(active: 0)
            format.html { redirect_to params[:custom_redirect], notice: @helpdesk_category.errors.full_messages.join(" , ") }
            format.json { render json: @helpdesk_category.errors, status: :unprocessable_entity }
          else
            format.html { redirect_to params[:custom_redirect], notice: @helpdesk_category.errors.full_messages.join(" , ") }
            format.json { render json: @helpdesk_category.errors, status: :unprocessable_entity }
          end
        end
      end

      # DELETE /helpdesk_categories/1
      # DELETE /helpdesk_categories/1.json
      def destroy
        @helpdesk_category.destroy
        respond_to do |format|
          format.html { redirect_to helpdesk_categories_url, notice: 'Helpdesk category was successfully destroyed.' }
          format.json { head :no_content }
        end
      end

      def web_view_reports
        @user = params.has_key?(:token) ? User.find_by(api_key: params[:token]) : spree_current_user
        User.current = @user
        unless @user
          render "not_authorised", :layout => false and return
        end
        @curusoc = @user.try(:selected_user_society).try(:user_society)

        @date_rangeparam = params[:q][:date_range] unless !params[:q].present?
        @page_name = "Helpdesk Report"
        if params[:commit] == "Apply" && params[:q][:date_range].present?
          @date_range_without_format = params[:q][:date_range]
          @date_range = params[:q][:date_range].split(" - ")
          params[:q][:created_at_lteq] = Date.strptime(@date_range[1], "%m/%d/%Y").strftime("%d/%m/%Y")
          params[:q][:created_at_gteq] = Date.strptime(@date_range[0], "%m/%d/%Y").strftime("%d/%m/%Y")
        else
          params[:q] = {"created_at_gteq"=>DateTime.now.beginning_of_month, "created_at_lteq"=>DateTime.now}
        end
        oparams = Hash.new
        oparams = params[:q]
        # current_month = {"created_at_gteq"=>(DateTime.now).beginning_of_month, "created_at_lteq"=>(DateTime.now).end_of_month}

        # @complaint_currrent_month = Complaint.where(id_society: @curusoc.id_society).search(current_month).result

        @complaints = Complaint.pms.where(id_society: @curusoc.id_society).search(params[:q]).result.order("complaints.id desc")

        # if @complaints.blank?
        #   flash.now[:error_message] = "No, Results Found"
        # end

        @statuses = ComplaintStatus.pms.active.where(society_id: @curusoc.id_society)

        @helpdesk_categories = HelpdeskCategory.pms.active.where(society_id: @curusoc.id_society)

        ####################################Complaint Category Drilldown Report(1 Level Drilldown)####################

        @highchart_category_data_array = []
        @categorywise_drilldown = []
        @issue_types = IssueType.where(society_id: @curusoc.id_society)
        @issue_types.each do |it|
          basehash = Hash.new
          basehash[:name] = it.name
          htcgs = @helpdesk_categories.where(issue_type_id: it.id)
          basehash[:data] = []
          @category_count_including_zero = htcgs.map{|s|
            params[:w] = oparams
            params[:w][:issue_type_id_eq] = it.id
            params[:w][:category_type_id_eq] = s.id

            category_hash_fn = s.category_hash(s.name, "#{it.id}_#{s.id}", params[:w])
            if category_hash_fn[:ct] > 0
              basehash[:data] << category_hash_fn[:hs]
              @categorywise_drilldown << HelpdeskCategory.statuses_hash("#{s.name}", "#{it.id}_#{s.id}", @statuses, "", params[:w])
            end
          }
          @highchart_category_data_array << basehash
        end


        if params[:w].present?
          params[:w].delete(:issue_type_id_eq)
          params[:w].delete(:category_type_id_eq)
        end

        ####################################Complaint Rating Report(1 Level Drilldown)########################

        @highchart_complaintrating_data_array = []
        @highchart_complaintrating_drill = []

        complaint_rating_terrible = []
        complaint_rating_bad = []
        complaint_rating_okay = []
        complaint_rating_good = []
        complaint_rating_great = []

        @complaints.each do |complaint|
          if complaint.feedbacks.present?
            if complaint.feedbacks.last.rating == 1
              complaint_rating_terrible << complaint.id
            elsif complaint.feedbacks.last.rating == 2
              complaint_rating_bad << complaint.id
            elsif complaint.feedbacks.last.rating == 3
              complaint_rating_okay << complaint.id
            elsif complaint.feedbacks.last.rating == 4
              complaint_rating_good << complaint.id
            elsif complaint.feedbacks.last.rating == 5
              complaint_rating_great << complaint.id
            end
          end
        end

        rating_terrible=Complaint.where(id: complaint_rating_terrible)
        rating_bad=Complaint.where(id: complaint_rating_bad)
        rating_okay=Complaint.where(id: complaint_rating_okay)
        rating_good=Complaint.where(id: complaint_rating_good)
        rating_great=Complaint.where(id: complaint_rating_great)

        complaint_rating_grouping_hash= {name: "Terrible",drilldown: "terribleComplaint",y: rating_terrible.count},
          {name: "Bad",drilldown: "badComplaint",y: rating_bad.count},
          {name: "Okay",drilldown: "okayComplaint",y: rating_okay.count},
          {name: "Good",drilldown: "goodComplaint",y: rating_good.count},
          {name: "Great",drilldown: "greatComplaint",y: rating_great.count}

        @highchart_complaintrating_data_array = complaint_rating_grouping_hash

        complaint_rating_drill_grouping_hash={name: "Ticket Number",id: "terribleComplaint",data: rating_terrible.pluck(:ticket_number,:id)},
          {name: "Ticket Number",id: "badComplaint",data: rating_bad.pluck(:ticket_number,:id)},
          {name: "Ticket Number",id: "okayComplaint",data: rating_okay.pluck(:ticket_number,:id)},
          {name: "Ticket Number",id: "goodComplaint",data: rating_good.pluck(:ticket_number,:id)},
          {name: "Ticket Number",id: "greatComplaint",data: rating_great.pluck(:ticket_number,:id)}

        @highchart_complaintrating_drill = complaint_rating_drill_grouping_hash

        if params[:w].present?
          params[:w].delete(:issue_type_id_eq)
          params[:w].delete(:category_type_id_eq)
        end

        ####################################Complaint Type Drilldown Report(2 Level Drilldown)########################

        complaint_type_grouping_hash = []

        @highchart_complaint_type_data_array = complaint_type_grouping_hash
        @complaint_categories_drill = []

        ctypes = ["Complaint", "Request", "Suggestion"]

        @issue_types.each do |issue_type|
          mainhash = Hash.new
          mainhash[:name] = "#{issue_type.name}"
          mainhash[:data] = []
          ctypes.each do |ctype|
            ctypeid = "#{ctype}_#{issue_type.id}"

            main_subhash = Hash.new
            main_subhash[:name] = ctype
            main_subhash[:drilldown] = "#{ctypeid}"
            main_subhash[:y] = @complaints.where(complaint_type: ctype, issue_type_id: issue_type.id).count
            mainhash[:data] << main_subhash
            cchash = Hash.new

            cchash["id"] = ctypeid
            cchash["name"] = issue_type.name
            cchash["data"] = []
            params[:w] = {}
            @statuses.each do |status|
              params[:w] = oparams
              params[:w][:issue_type_id_eq] = issue_type.id
              params[:w][:issue_status_eq] = status.id
              params[:w][:complaint_type_eq] = ctype.split("_")[0]
              status_count_fn = HelpdeskCategory.status_count_hash("#{status.name}", "", status, "#{ctypeid}_Status_#{status.id}", params[:w])
              if status_count_fn[:ct] > 0
                cchash["data"] << status_count_fn[:hs]
                basehash = Hash.new
                basehash["id"] = "#{ctypeid}_Status_#{status.id}"
                basehash["name"] = issue_type.name
                basehash["data"] = []
                htcgs = @helpdesk_categories.where(issue_type_id: issue_type.id)
                htcgs.each do |s|
                  params[:w][:category_type_id_eq] = s.id
                  category_hash_fn = s.category_hash(s.name, "", params[:w])
                  if category_hash_fn[:ct] > 0
                    basehash["data"] << category_hash_fn[:hs]
                  end
                end
                @complaint_categories_drill << basehash
              end
              params[:w].delete(:category_type_id_eq)
            end
            @complaint_categories_drill << cchash
            params[:w].delete(:issue_type_id_eq)
            params[:w].delete(:category_type_id_eq)
          end
          complaint_type_grouping_hash << mainhash
        end


        @responsetat_achieved_id = []
        @responsetat_breached_id = []
        @responsetat_undefined_id = []
        @responsetat_notapplicable_id = []

        @helpdesk_categories.each do |hc|
          clogs = @complaints.present? ? ComplaintLog.search(complaint_id_in: @complaints.pluck(:id), complaint_category_type_id_eq: hc.id).result.where("complaint_status_id is not null").group_by {|c| c.complaint_id} : {}
          clogs.each do |complaint_id,clog|
            @complaint = Complaint.where(id: complaint_id).take
            crtime = clog.first.created_at.to_time
            if !@complaint.tat.present?
              @responsetat_undefined_id << @complaint.id
              next
            elsif clog.second.present?
              clogtime = clog.second.created_at.to_time
            else
              now = Time.zone.now
              clogtime = now.to_time
            end

            resptime = ((clogtime - crtime) / 60).to_i
            if now.present? && resptime <= @complaint.tat.to_i
              @responsetat_notapplicable_id << @complaint.id
            elsif resptime.to_i <=  @complaint.tat.to_i
              @responsetat_achieved_id << @complaint.id
            elsif resptime.to_i >  @complaint.tat.to_i
              @responsetat_breached_id << @complaint.id
            end
          end
        end

        @ResponseTatAcheived = @responsetat_achieved_id
        @ResponseTatBreached = @responsetat_breached_id
        @ResponseUndefined =  @responsetat_undefined_id
        @ResponseNotApplicable =  @responsetat_notapplicable_id

        ####################################Complaint Response & Resolution Drilldown Report(1 Level Drilldown)########################

        @respachieved_current = Complaint.where(id: @ResponseTatAcheived)
        @respbreached_current = Complaint.where(id: @ResponseTatBreached)
        @responsetat_undefined = Complaint.where(id: @ResponseUndefined)
        @responsetat_notapplicable = Complaint.where(id: @ResponseNotApplicable)


        @highchart_current_responsetat_data_array = []
        @highchart_current_responsetat_drill = []

        responsetat_current_grouping_hash= {name: "Response Achieved",drilldown: "respAchievedCurrent",y: @respachieved_current.count,color: '#398439'},
          {name: "Response Breached",drilldown: "respBreachedCurrent",y: @respbreached_current.count,color: '#dd4b39'},
          {name: "Response Undefined",drilldown: "respUndefined",y: @responsetat_undefined.count,color: '#e08e0b'},
          {name: "Response Not Applicable",drilldown: "respNotApplicable",y: @responsetat_notapplicable.count,color: '#999999'}

        @highchart_current_responsetat_data_array = responsetat_current_grouping_hash

        response_tat_current_drill_grouping_hash={name: "Achieved Category",id: "respAchievedCurrent",data: @respachieved_current.joins(:category_type).group('helpdesk_categories.name').count.to_a},
          {name: "Breached Category",id: "respBreachedCurrent",data: @respbreached_current.joins(:category_type).group('helpdesk_categories.name').count.to_a},
          {name: "Undefined Category",id: "respUndefined",data: @responsetat_undefined.joins(:category_type).group('helpdesk_categories.name').count.to_a},
          {name: "Not Applicable Category",id: "respNotApplicable",data: @responsetat_notapplicable.joins(:category_type).group('helpdesk_categories.name').count.to_a}

        @highchart_current_responsetat_drill = response_tat_current_drill_grouping_hash


        @resolutionbreached_current = @complaints.search(esc_histories_escalation_matrix_complaint_worker_esc_type_eq: "resolution").result.uniq
        @resolutionachieved_current = @complaints.where.not(id: @resolutionbreached_current.pluck(:id))


        @highchart_current_resolutiontat_data_array = []
        @highchart_current_resolutiontat_drill = []

        resolutiontat_current_grouping_hash= @resolutionachieved_current.count > 0 ? {name: "Resolution Achieved",drilldown: "resolutionAchievedCurrent",y: @resolutionachieved_current.count,color: '#398439'} : {},
          @resolutionbreached_current.count > 0 ? {name: "Resolution Breached",drilldown: "resolutionBreachedCurrent",y: @resolutionbreached_current.count,color: '#dd4b39'} : {}

        @highchart_current_resolutiontat_data_array = resolutiontat_current_grouping_hash

        resolution_tat_current_drill_grouping_hash={name: "Achieved Category",id: "resolutionAchievedCurrent",data: @resolutionachieved_current.joins(:category_type).group('helpdesk_categories.name').count.to_a},
          {name: "Breached Category",id: "resolutionBreachedCurrent",data: @resolutionbreached_current.joins(:category_type).group('helpdesk_categories.name').count.to_a}

        @highchart_current_resolutiontat_drill = resolution_tat_current_drill_grouping_hash

        render :layout=> false

      end


      # def helpdesk_charts
      #   oparams = Hash.new
      #   oparams = params[:q] unless !params[:q].present?
      #   @date_rangeparam = params[:q][:date_range] unless !params[:q].present?
      #   @complaints = Society.find_by(id: @curusoc.id_society).complaints.search(params[:q]).result.order("complaints.id desc")
      #   @statuses = ComplaintStatus.active.where(society_id: @curusoc.id_society)

      #   @helpdesk_categories = HelpdeskCategory.active.where(society_id: @curusoc.id_society)
      #   @helpdesk_sub_categories = HelpdeskSubCategory.active.where(helpdesk_category_id: @helpdesk_categories.pluck(:id))

      #   ###################################Complaint Category Drilldown Report(1 Level Drilldown)####################

      #   @highchart_category_data_array = []
      #   @categorywise_drilldown = []
      #   @issue_types = IssueType.where(society_id: @curusoc.id_society)
      #   @issue_types.each do |it|
      #     basehash = Hash.new
      #     basehash[:name] = it.name
      #     htcgs = @helpdesk_categories.where(issue_type_id: it.id)
      #     basehash[:data] = []
      #     @category_count_including_zero = htcgs.map{|s|
      #       params[:w] = oparams
      #       params[:w][:issue_type_id_eq] = it.id
      #       params[:w][:category_type_id_eq] = s.id
      #       category_hash_fn = s.category_hash(s.name, "#{it.id}_#{s.id}", params[:w])
      #       if category_hash_fn[:ct] > 0
      #         basehash[:data] << category_hash_fn[:hs]
      #         @categorywise_drilldown << HelpdeskCategory.statuses_hash("#{s.name}", "#{it.id}_#{s.id}", @statuses, "", params[:w])
      #       end
      #     }
      #     @highchart_category_data_array << basehash
      #   end


      #   if params[:w].present?
      #     params[:w].delete(:issue_type_id_eq)
      #     params[:w].delete(:category_type_id_eq)
      #   end

      #   ##############################################Subcategory Report######################################

      #   @subcategorywise_drilldown = []
      #   @highchart_subcategory_data_array = []
      #   @issue_types.each do |it|
      #     basehash = Hash.new
      #     basehash[:name] = it.name
      #     htcgs = @helpdesk_categories.where(issue_type_id: it.id)
      #     basehash[:data] = []
      #     @category_count_including_zero = htcgs.map{|s|
      #       params[:w] = oparams
      #       params[:w][:issue_type_id_eq] = it.id
      #       params[:w][:category_type_id_eq] = s.id
      #       category_hash_fn = s.category_hash(s.name, "#{it.id}_#{s.id}", params[:w])
      #       # binding.pry
      #       if category_hash_fn[:ct] > 0
      #         basehash[:data] << category_hash_fn[:hs]
      #         @subcategorywise_drilldown << HelpdeskCategory.subcategories_hash("#{s.name}", "#{it.id}_#{s.id}", @helpdesk_sub_categories, "", params[:w])
      #       end
      #     }
      #     @highchart_subcategory_data_array << basehash
      #   end

      #   if params[:w].present?
      #     params[:w].delete(:issue_type_id_eq)
      #     params[:w].delete(:category_type_id_eq)
      #   end

      #   ####################################Complaint Rating Report(1 Level Drilldown)########################

      #   @highchart_complaintrating_data_array = []
      #   @highchart_complaintrating_drill = []

      #   complaint_rating_terrible = []
      #   complaint_rating_bad = []
      #   complaint_rating_okay = []
      #   complaint_rating_good = []
      #   complaint_rating_great = []

      #   @complaints.each do |complaint|
      #     if complaint.feedbacks.present?
      #       if complaint.feedbacks.last.rating == 1
      #         complaint_rating_terrible << complaint.id
      #       elsif complaint.feedbacks.last.rating == 2
      #         complaint_rating_bad << complaint.id
      #       elsif complaint.feedbacks.last.rating == 3
      #         complaint_rating_okay << complaint.id
      #       elsif complaint.feedbacks.last.rating == 4
      #         complaint_rating_good << complaint.id
      #       elsif complaint.feedbacks.last.rating == 5
      #         complaint_rating_great << complaint.id
      #       end
      #     end
      #   end

      #   rating_terrible=Complaint.where(id: complaint_rating_terrible)
      #   rating_bad=Complaint.where(id: complaint_rating_bad)
      #   rating_okay=Complaint.where(id: complaint_rating_okay)
      #   rating_good=Complaint.where(id: complaint_rating_good)
      #   rating_great=Complaint.where(id: complaint_rating_great)

      #   complaint_rating_grouping_hash= {name: "Terrible",drilldown: "terribleComplaint",y: rating_terrible.count},
      #                                   {name: "Bad",drilldown: "badComplaint",y: rating_bad.count},
      #                                   {name: "Okay",drilldown: "okayComplaint",y: rating_okay.count},
      #                                   {name: "Good",drilldown: "goodComplaint",y: rating_good.count},
      #                                   {name: "Great",drilldown: "greatComplaint",y: rating_great.count}

      #   # @highchart_complaintrating_data_array = (rating_terrible.count != 0 || rating_bad.count != 0 || rating_okay.count != 0 ||rating_good.count != 0 || rating_great.count != 0) ? complaint_rating_grouping_hash : []

      #   complaint_rating_grouping_hash.each do |index |
      #     if index[:y] > 0
      #        @highchart_complaintrating_data_array << index
      #     end
      #   end

      #   complaint_rating_drill_grouping_hash={name: "Ticket Number",id: "terribleComplaint",data: rating_terrible.pluck(:ticket_number,:id),innerSize: '50%'},
      #                                    {name: "Ticket Number",id: "badComplaint",data: rating_bad.pluck(:ticket_number,:id),innerSize: '50%'},
      #                                    {name: "Ticket Number",id: "okayComplaint",data: rating_okay.pluck(:ticket_number,:id),innerSize: '50%'},
      #                                    {name: "Ticket Number",id: "goodComplaint",data: rating_good.pluck(:ticket_number,:id),innerSize: '50%'},
      #                                    {name: "Ticket Number",id: "greatComplaint",data: rating_great.pluck(:ticket_number,:id),innerSize: '50%'}

      #   @highchart_complaintrating_drill = complaint_rating_drill_grouping_hash

      #   if params[:w].present?
      #     params[:w].delete(:issue_type_id_eq)
      #     params[:w].delete(:category_type_id_eq)
      #   end

      #   ####################################Complaint Type Drilldown Report(2 Level Drilldown)########################

      #   complaint_type_grouping_hash = []

      #   @highchart_complaint_type_data_array = complaint_type_grouping_hash
      #   @complaint_categories_drill = []

      #   ctypes = ["Complaint", "Request", "Suggestion"]

      #   @issue_types.each do |issue_type|
      #     mainhash = Hash.new
      #     mainhash[:name] = "#{issue_type.name}"
      #     mainhash[:data] = []
      #     ctypes.each do |ctype|
      #       ctypeid = "#{ctype}_#{issue_type.id}"

      #       main_subhash = Hash.new
      #       main_subhash[:name] = ctype
      #       main_subhash[:drilldown] = "#{ctypeid}"
      #       main_subhash[:y] = @complaints.where(complaint_type: ctype, issue_type_id: issue_type.id).count
      #       mainhash[:data] << main_subhash
      #       cchash = Hash.new

      #       cchash["id"] = ctypeid
      #       cchash["name"] = issue_type.name
      #       cchash["data"] = []
      #       params[:w] = {}
      #       @statuses.each do |status|
      #         params[:w] = oparams
      #         params[:w][:issue_type_id_eq] = issue_type.id
      #         params[:w][:issue_status_eq] = status.id
      #         params[:w][:complaint_type_eq] = ctype.split("_")[0]
      #         status_count_fn = HelpdeskCategory.status_count_hash("#{status.name}", "", status, "#{ctypeid}_Status_#{status.id}", params[:w])
      #         if status_count_fn[:ct] > 0
      #           cchash["data"] << status_count_fn[:hs]
      #           basehash = Hash.new
      #           basehash["id"] = "#{ctypeid}_Status_#{status.id}"
      #           basehash["name"] = issue_type.name
      #           basehash["data"] = []
      #           htcgs = @helpdesk_categories.where(issue_type_id: issue_type.id)
      #           htcgs.each do |s|
      #             params[:w][:category_type_id_eq] = s.id
      #             category_hash_fn = s.category_hash(s.name, "", params[:w])
      #             if category_hash_fn[:ct] > 0
      #               basehash["data"] << category_hash_fn[:hs]
      #             end
      #           end
      #           @complaint_categories_drill << basehash
      #         end
      #         params[:w].delete(:category_type_id_eq)
      #       end
      #       @complaint_categories_drill << cchash
      #       params[:w].delete(:issue_type_id_eq)
      #       params[:w].delete(:category_type_id_eq)
      #     end
      #     complaint_type_grouping_hash << mainhash
      #   end


      #   @responsetat_achieved_id = []
      #   @responsetat_breached_id = []
      #   @responsetat_undefined_id = []
      #   @responsetat_notapplicable_id = []

      #   @helpdesk_categories.each do |hc|
      #     clogs = @complaints.present? ? ComplaintLog.search(complaint_id_in: @complaints.pluck(:id), complaint_category_type_id_eq: hc.id).result.where("complaint_status_id is not null").group_by {|c| c.complaint_id} : {}
      #     clogs.each do |complaint_id,clog|
      #       @complaint = Complaint.where(id: complaint_id).take
      #       crtime = clog.first.created_at.to_time
      #       if !@complaint.tat.present?
      #         @responsetat_undefined_id << @complaint.id
      #         next
      #       elsif clog.second.present?
      #         clogtime = clog.second.created_at.to_time
      #       else
      #         now = Time.zone.now
      #         clogtime = now.to_time
      #       end

      #       resptime = ((clogtime - crtime) / 60).to_i
      #       if now.present? && resptime <= @complaint.tat.to_i
      #         @responsetat_notapplicable_id << @complaint.id
      #       elsif resptime.to_i <=  @complaint.tat.to_i
      #         @responsetat_achieved_id << @complaint.id
      #       elsif resptime.to_i >  @complaint.tat.to_i
      #         @responsetat_breached_id << @complaint.id
      #       end
      #     end
      #   end

      #   @ResponseTatAcheived = @responsetat_achieved_id
      #   @ResponseTatBreached = @responsetat_breached_id
      #   @ResponseUndefined =  @responsetat_undefined_id
      #   @ResponseNotApplicable =  @responsetat_notapplicable_id

      #   ####################################Complaint Response & Resolution Drilldown Report(1 Level Drilldown)########################

      #   @respachieved_current = Complaint.where(id: @ResponseTatAcheived)
      #   @respbreached_current = Complaint.where(id: @ResponseTatBreached)
      #   @responsetat_undefined = Complaint.where(id: @ResponseUndefined)
      #   @responsetat_notapplicable = Complaint.where(id: @ResponseNotApplicable)


      #   @highchart_current_responsetat_data_array = []
      #   @highchart_current_responsetat_drill = []

      #   responsetat_current_grouping_hash= {name: "Response Achieved",drilldown: "respAchievedCurrent",y: @respachieved_current.count,color: '#398439'},
      #                               {name: "Response Breached",drilldown: "respBreachedCurrent",y: @respbreached_current.count,color: '#dd4b39'},
      #                               {name: "Response Undefined",drilldown: "respUndefined",y: @responsetat_undefined.count,color: '#e08e0b'},
      #                               {name: "Response Not Applicable",drilldown: "respNotApplicable",y: @responsetat_notapplicable.count,color: '#999999'}

      #   @highchart_current_responsetat_data_array = responsetat_current_grouping_hash

      #   response_tat_current_drill_grouping_hash={name: "Achieved Category",id: "respAchievedCurrent",data: @respachieved_current.joins(:category_type).group('helpdesk_categories.name').count.to_a,innerSize: '50%'},
      #                                {name: "Breached Category",id: "respBreachedCurrent",data: @respbreached_current.joins(:category_type).group('helpdesk_categories.name').count.to_a,innerSize: '50%'},
      #                                {name: "Undefined Category",id: "respUndefined",data: @responsetat_undefined.joins(:category_type).group('helpdesk_categories.name').count.to_a,innerSize: '50%'},
      #                                {name: "Not Applicable Category",id: "respNotApplicable",data: @responsetat_notapplicable.joins(:category_type).group('helpdesk_categories.name').count.to_a,innerSize: '50%'}

      #   @highchart_current_responsetat_drill = response_tat_current_drill_grouping_hash


      #   @resolutionbreached_current = @complaints.search(esc_histories_escalation_matrix_complaint_worker_esc_type_eq: "resolution").result.uniq
      #   @resolutionachieved_current = @complaints.where.not(id: @resolutionbreached_current.pluck(:id))


      #   @highchart_current_resolutiontat_data_array = []
      #   @highchart_current_resolutiontat_drill = []

      #   resolutiontat_current_grouping_hash= @resolutionachieved_current.count > 0 ? {name: "Resolution Achieved",drilldown: "resolutionAchievedCurrent",y: @resolutionachieved_current.count,color: '#398439'} : {},
      #                               @resolutionbreached_current.count > 0 ? {name: "Resolution Breached",drilldown: "resolutionBreachedCurrent",y: @resolutionbreached_current.count,color: '#dd4b39'} : {}

      #   @highchart_current_resolutiontat_data_array = resolutiontat_current_grouping_hash

      #   resolution_tat_current_drill_grouping_hash={name: "Achieved Category",id: "resolutionAchievedCurrent",data: @resolutionachieved_current.joins(:category_type).group('helpdesk_categories.name').count.to_a,innerSize: '50%'},
      #                                {name: "Breached Category",id: "resolutionBreachedCurrent",data: @resolutionbreached_current.joins(:category_type).group('helpdesk_categories.name').count.to_a,innerSize: '50%'}

      #   @highchart_current_resolutiontat_drill = resolution_tat_current_drill_grouping_hash
      #   respond_to do |format|
      #     format.js
      #   end
      # end


      # def helpdesk_reports
      #   @date_rangeparam = params[:q][:date_range] unless !params[:q].present?
      #   @page_name = "Helpdesk Report"
      #   if params[:commit] == "Apply" && params[:q][:date_range].present?
      #     @date_range_without_format = params[:q][:date_range]
      #     @date_range = params[:q][:date_range].split(" - ")
      #     params[:q][:created_at_lteq] = Date.strptime(@date_range[1], "%m/%d/%Y").strftime("%d/%m/%Y")
      #     params[:q][:created_at_gteq] = Date.strptime(@date_range[0], "%m/%d/%Y").strftime("%d/%m/%Y")
      #   else
      #     params[:q] = {"created_at_gteq"=>DateTime.now.beginning_of_month, "created_at_lteq"=>DateTime.now}
      #   end
      #   oparams = Hash.new
      #   oparams = params[:q]
      #   # current_month = {"created_at_gteq"=>(DateTime.now).beginning_of_month, "created_at_lteq"=>(DateTime.now).end_of_month}

      #   # @complaint_currrent_month = Complaint.where(id_society: @curusoc.id_society).search(current_month).result

      #   @complaints = Complaint.where(id_society: @curusoc.id_society).search(params[:q]).result.order("complaints.id desc")

      #   # if @complaints.blank?
      #   #   flash.now[:error_message] = "No, Results Found"
      #   # end

      #   @statuses = ComplaintStatus.active.where(society_id: @curusoc.id_society)

      #   @helpdesk_categories = HelpdeskCategory.active.where(society_id: @curusoc.id_society)

      #   ####################################Complaint Category Drilldown Report(1 Level Drilldown)####################

      #   @highchart_category_data_array = []
      #   @categorywise_drilldown = []
      #   @issue_types = IssueType.where(society_id: @curusoc.id_society)
      #   @issue_types.each do |it|
      #     basehash = Hash.new
      #     basehash[:name] = it.name
      #     htcgs = @helpdesk_categories.where(issue_type_id: it.id)
      #     basehash[:data] = []
      #     @category_count_including_zero = htcgs.map{|s|
      #       params[:w] = oparams
      #       params[:w][:issue_type_id_eq] = it.id
      #       params[:w][:category_type_id_eq] = s.id
      #       # binding.pry
      #       category_hash_fn = s.category_hash(s.name, "#{it.id}_#{s.id}", params[:w])
      #       if category_hash_fn[:ct] > 0
      #         basehash[:data] << category_hash_fn[:hs]
      #         @categorywise_drilldown << HelpdeskCategory.statuses_hash("#{s.name}", "#{it.id}_#{s.id}", @statuses, "", params[:w])
      #       end
      #     }
      #     @highchart_category_data_array << basehash
      #   end


      #   if params[:w].present?
      #     params[:w].delete(:issue_type_id_eq)
      #     params[:w].delete(:category_type_id_eq)
      #   end

      #   ####################################Complaint Rating Report(1 Level Drilldown)########################

      #   @highchart_complaintrating_data_array = []
      #   @highchart_complaintrating_drill = []

      #   complaint_rating_terrible = []
      #   complaint_rating_bad = []
      #   complaint_rating_okay = []
      #   complaint_rating_good = []
      #   complaint_rating_great = []

      #   @complaints.each do |complaint|
      #     if complaint.feedbacks.present?
      #       if complaint.feedbacks.last.rating == 1
      #         complaint_rating_terrible << complaint.id
      #       elsif complaint.feedbacks.last.rating == 2
      #         complaint_rating_bad << complaint.id
      #       elsif complaint.feedbacks.last.rating == 3
      #         complaint_rating_okay << complaint.id
      #       elsif complaint.feedbacks.last.rating == 4
      #         complaint_rating_good << complaint.id
      #       elsif complaint.feedbacks.last.rating == 5
      #         complaint_rating_great << complaint.id
      #       end
      #     end
      #   end

      #   rating_terrible=Complaint.where(id: complaint_rating_terrible)
      #   rating_bad=Complaint.where(id: complaint_rating_bad)
      #   rating_okay=Complaint.where(id: complaint_rating_okay)
      #   rating_good=Complaint.where(id: complaint_rating_good)
      #   rating_great=Complaint.where(id: complaint_rating_great)

      #   complaint_rating_grouping_hash= {name: "Terrible",drilldown: "terribleComplaint",y: rating_terrible.count},
      #                                   {name: "Bad",drilldown: "badComplaint",y: rating_bad.count},
      #                                   {name: "Okay",drilldown: "okayComplaint",y: rating_okay.count},
      #                                   {name: "Good",drilldown: "goodComplaint",y: rating_good.count},
      #                                   {name: "Great",drilldown: "greatComplaint",y: rating_great.count}

      #   @highchart_complaintrating_data_array = complaint_rating_grouping_hash

      #   complaint_rating_drill_grouping_hash={name: "Ticket Number",id: "terribleComplaint",data: rating_terrible.pluck(:ticket_number,:id)},
      #                                    {name: "Ticket Number",id: "badComplaint",data: rating_bad.pluck(:ticket_number,:id)},
      #                                    {name: "Ticket Number",id: "okayComplaint",data: rating_okay.pluck(:ticket_number,:id)},
      #                                    {name: "Ticket Number",id: "goodComplaint",data: rating_good.pluck(:ticket_number,:id)},
      #                                    {name: "Ticket Number",id: "greatComplaint",data: rating_great.pluck(:ticket_number,:id)}

      #   @highchart_complaintrating_drill = complaint_rating_drill_grouping_hash

      #   if params[:w].present?
      #     params[:w].delete(:issue_type_id_eq)
      #     params[:w].delete(:category_type_id_eq)
      #   end

      #   ####################################Complaint Type Drilldown Report(2 Level Drilldown)########################

      #   complaint_type_grouping_hash = []

      #   @highchart_complaint_type_data_array = complaint_type_grouping_hash
      #   @complaint_categories_drill = []

      #   ctypes = ["Complaint", "Request", "Suggestion"]

      #   @issue_types.each do |issue_type|
      #     mainhash = Hash.new
      #     mainhash[:name] = "#{issue_type.name}"
      #     mainhash[:data] = []
      #     ctypes.each do |ctype|
      #       ctypeid = "#{ctype}_#{issue_type.id}"

      #       main_subhash = Hash.new
      #       main_subhash[:name] = ctype
      #       main_subhash[:drilldown] = "#{ctypeid}"
      #       main_subhash[:y] = @complaints.where(complaint_type: ctype, issue_type_id: issue_type.id).count
      #       mainhash[:data] << main_subhash
      #       cchash = Hash.new

      #       cchash["id"] = ctypeid
      #       cchash["name"] = issue_type.name
      #       cchash["data"] = []
      #       params[:w] = {}
      #       @statuses.each do |status|
      #         params[:w] = oparams
      #         params[:w][:issue_type_id_eq] = issue_type.id
      #         params[:w][:issue_status_eq] = status.id
      #         params[:w][:complaint_type_eq] = ctype.split("_")[0]
      #         status_count_fn = HelpdeskCategory.status_count_hash("#{status.name}", "", status, "#{ctypeid}_Status_#{status.id}", params[:w])
      #         if status_count_fn[:ct] > 0
      #           cchash["data"] << status_count_fn[:hs]
      #           basehash = Hash.new
      #           basehash["id"] = "#{ctypeid}_Status_#{status.id}"
      #           basehash["name"] = issue_type.name
      #           basehash["data"] = []
      #           htcgs = @helpdesk_categories.where(issue_type_id: issue_type.id)
      #           htcgs.each do |s|
      #             params[:w][:category_type_id_eq] = s.id
      #             category_hash_fn = s.category_hash(s.name, "", params[:w])
      #             if category_hash_fn[:ct] > 0
      #               basehash["data"] << category_hash_fn[:hs]
      #             end
      #           end
      #           @complaint_categories_drill << basehash
      #         end
      #         params[:w].delete(:category_type_id_eq)
      #       end
      #       @complaint_categories_drill << cchash
      #       params[:w].delete(:issue_type_id_eq)
      #       params[:w].delete(:category_type_id_eq)
      #     end
      #     complaint_type_grouping_hash << mainhash
      #   end


      #   @responsetat_achieved_id = []
      #   @responsetat_breached_id = []
      #   @responsetat_undefined_id = []
      #   @responsetat_notapplicable_id = []

      #   @helpdesk_categories.each do |hc|
      #     clogs = @complaints.present? ? ComplaintLog.search(complaint_id_in: @complaints.pluck(:id), complaint_category_type_id_eq: hc.id).result.where("complaint_status_id is not null").group_by {|c| c.complaint_id} : {}
      #     clogs.each do |complaint_id,clog|
      #       @complaint = Complaint.where(id: complaint_id).take
      #       crtime = clog.first.created_at.to_time
      #       if !@complaint.tat.present?
      #         @responsetat_undefined_id << @complaint.id
      #         next
      #       elsif clog.second.present?
      #         clogtime = clog.second.created_at.to_time
      #       else
      #         now = Time.zone.now
      #         clogtime = now.to_time
      #       end

      #       resptime = ((clogtime - crtime) / 60).to_i
      #       if now.present? && resptime <= @complaint.tat.to_i
      #         @responsetat_notapplicable_id << @complaint.id
      #       elsif resptime.to_i <=  @complaint.tat.to_i
      #         @responsetat_achieved_id << @complaint.id
      #       elsif resptime.to_i >  @complaint.tat.to_i
      #         @responsetat_breached_id << @complaint.id
      #       end
      #     end
      #   end

      #   @ResponseTatAcheived = @responsetat_achieved_id
      #   @ResponseTatBreached = @responsetat_breached_id
      #   @ResponseUndefined =  @responsetat_undefined_id
      #   @ResponseNotApplicable =  @responsetat_notapplicable_id

      #   ####################################Complaint Response & Resolution Drilldown Report(1 Level Drilldown)########################

      #     @respachieved_current = Complaint.where(id: @ResponseTatAcheived)
      #     @respbreached_current = Complaint.where(id: @ResponseTatBreached)
      #     @responsetat_undefined = Complaint.where(id: @ResponseUndefined)
      #     @responsetat_notapplicable = Complaint.where(id: @ResponseNotApplicable)


      #     @highchart_current_responsetat_data_array = []
      #     @highchart_current_responsetat_drill = []

      #     responsetat_current_grouping_hash= {name: "Response Achieved",drilldown: "respAchievedCurrent",y: @respachieved_current.count,color: '#398439'},
      #                                 {name: "Response Breached",drilldown: "respBreachedCurrent",y: @respbreached_current.count,color: '#dd4b39'},
      #                                 {name: "Response Undefined",drilldown: "respUndefined",y: @responsetat_undefined.count,color: '#e08e0b'},
      #                                 {name: "Response Not Applicable",drilldown: "respNotApplicable",y: @responsetat_notapplicable.count,color: '#999999'}

      #     @highchart_current_responsetat_data_array = responsetat_current_grouping_hash

      #     response_tat_current_drill_grouping_hash={name: "Achieved Category",id: "respAchievedCurrent",data: @respachieved_current.joins(:category_type).group('helpdesk_categories.name').count.to_a},
      #                                  {name: "Breached Category",id: "respBreachedCurrent",data: @respbreached_current.joins(:category_type).group('helpdesk_categories.name').count.to_a},
      #                                  {name: "Undefined Category",id: "respUndefined",data: @responsetat_undefined.joins(:category_type).group('helpdesk_categories.name').count.to_a},
      #                                  {name: "Not Applicable Category",id: "respNotApplicable",data: @responsetat_notapplicable.joins(:category_type).group('helpdesk_categories.name').count.to_a}

      #     @highchart_current_responsetat_drill = response_tat_current_drill_grouping_hash


      #     @resolutionbreached_current = @complaints.search(esc_histories_escalation_matrix_complaint_worker_esc_type_eq: "resolution").result.uniq
      #     @resolutionachieved_current = @complaints.where.not(id: @resolutionbreached_current.pluck(:id))


      #     @highchart_current_resolutiontat_data_array = []
      #     @highchart_current_resolutiontat_drill = []

      #     resolutiontat_current_grouping_hash= @resolutionachieved_current.count > 0 ? {name: "Resolution Achieved",drilldown: "resolutionAchievedCurrent",y: @resolutionachieved_current.count,color: '#398439'} : {},
      #                                 @resolutionbreached_current.count > 0 ? {name: "Resolution Breached",drilldown: "resolutionBreachedCurrent",y: @resolutionbreached_current.count,color: '#dd4b39'} : {}

      #     @highchart_current_resolutiontat_data_array = resolutiontat_current_grouping_hash

      #     resolution_tat_current_drill_grouping_hash={name: "Achieved Category",id: "resolutionAchievedCurrent",data: @resolutionachieved_current.joins(:category_type).group('helpdesk_categories.name').count.to_a},
      #                                  {name: "Breached Category",id: "resolutionBreachedCurrent",data: @resolutionbreached_current.joins(:category_type).group('helpdesk_categories.name').count.to_a}

      #     @highchart_current_resolutiontat_drill = resolution_tat_current_drill_grouping_hash

      #   end

      def compare_response_chart

        if params[:q][:response_date_range1].present? && params[:q][:response_date_range2].present?

          @date_range1 = params[:q][:response_date_range1].split(" - ")
          to1 = Date.strptime(@date_range1[1], "%m/%d/%Y").strftime("%d/%m/%Y")
          from1 = Date.strptime(@date_range1[0], "%m/%d/%Y").strftime("%d/%m/%Y")
          response_date_range1 = {"created_at_gteq"=>from1, "created_at_lteq"=>to1}

          @date_range2 = params[:q][:response_date_range2].split(" - ")
          to2 = Date.strptime(@date_range2[1], "%m/%d/%Y").strftime("%d/%m/%Y")
          from2 = Date.strptime(@date_range2[0], "%m/%d/%Y").strftime("%d/%m/%Y")
          response_date_range2 = {"created_at_gteq"=>from2, "created_at_lteq"=>to2}

          @helpdesk_categories = HelpdeskCategory.active.where(society_id: @curusoc.id_society)
          render json: HelpdeskCategory.compare_response_chart_logic(@curusoc.id_society,@helpdesk_categories,response_date_range1,response_date_range2)

        end

      end


      def compare_resolution_chart

        if params[:q][:resolution_date_range1].present? && params[:q][:resolution_date_range2].present?

          @resolution_date_range1 = params[:q][:resolution_date_range1].split(" - ")
          resolution_to1 = Date.strptime(@resolution_date_range1[1], "%m/%d/%Y").strftime("%d/%m/%Y")
          resolution_from1 = Date.strptime(@resolution_date_range1[0], "%m/%d/%Y").strftime("%d/%m/%Y")
          resolution_date_range1 = {"created_at_gteq"=>resolution_from1, "created_at_lteq"=>resolution_to1}

          @resolution_date_range2 = params[:q][:resolution_date_range2].split(" - ")
          resolution_to2 = Date.strptime(@resolution_date_range2[1], "%m/%d/%Y").strftime("%d/%m/%Y")
          resolution_from2 = Date.strptime(@resolution_date_range2[0], "%m/%d/%Y").strftime("%d/%m/%Y")
          resolution_date_range2 = {"created_at_gteq"=>resolution_from2, "created_at_lteq"=>resolution_to2}

          render json: HelpdeskCategory.compare_resolution_chart_logic(@curusoc.id_society,resolution_date_range1,resolution_date_range2)

        end

      end

      def visitors_reports
        @page_name = "Visitors Report"
      end

      def staffs_reports
        @page_name = "Staffs Report"
      end

      def facility_reports
        @page_name = "Facility Report"
      end

      def get_sub_categories
        if params[:helpdesk_category_id].present? || params[:category_type_id].present? || (params[:q] && params[:q][:helpdesk_category_id_eq].present?)
          category_id = params[:helpdesk_category_id] || params[:category_type_id] || params[:q][:helpdesk_category_id_eq]

          helpdesk_category = HelpdeskCategory.find_by(id: category_id)

          if helpdesk_category
            @assigned_to = helpdesk_category.assignee_id
            @sub_categories = helpdesk_category.helpdesk_sub_categories

            # Filter by sub_category_id if present in the route
            if params[:id].present?
              @sub_categories = @sub_categories.where(id: params[:id])
            end

            render json: { sub_categories: @sub_categories }
          else
            render json: { error: 'HelpdeskCategory not found' }, status: :not_found
          end
        else
          @sub_categories = HelpdeskSubCategory.joins(:helpdesk_category)
          .where(helpdesk_categories: { society_id: @user.current_site_id })

          # Filter by sub_category_id if present in the route
          if params[:id].present?
            @sub_categories = @sub_categories.where(id: params[:id])
          end

          render :get_sub_categories
        end
      end




      def get_pms_sub_categories
        if params[:q].present? && params[:q][:helpdesk_category_id_eq].present?
          @subcatg = HelpdeskSubCategory.where(helpdesk_category_id: params[:q][:helpdesk_category_id_eq])
        else
          @subcatg = HelpdeskSubCategory.where(society_id: current_user.current_site_id) || []
        end
        respond_to do |format|
          format.json do
            render json: { sub_category: @subcatg.as_json }
          end
        end
      end

      def create_aging_rule
        @aging_rule = AgingRule.new(aging_rule_params.merge(site_id: @user.try(:selected_pms_site).try(:pms_site).try(:id),of_phase: "pms"))
        respond_to do |format|
          if @aging_rule.save
            format.html { redirect_to params[:custom_redirect] , notice: 'Aging Rule saved Successfully'}
          else
            format.html { redirect_to params[:custom_redirect] , danger: @aging_rule.errors.full_messages.join(" , ")}
          end
        end
      end

      def delete_aging_rule
        aging_rule = AgingRule.find(params[:id])
        aging_rule.update(active: 0)
        redirect_to params[:custom_redirect] , notice: 'Aging Rule Deleted Successfully'
      end

      def create_reopen
        @reopenstatus = ReopenStatus.where(society_id: @user.current_site_id).try(:last)
        if @reopenstatus.present?
          @reopenstatus.update(period_type: params[:period_type], time_period: params[:time_period])
        else
          @reopenstatus = ReopenStatus.create(period_type: params[:period_type], time_period: params[:time_period], society_id: @user.current_site_id, created_by: @user.id)
        end
        respond_to do |format|
          format.html { redirect_to "/pms/admin/helpdesk_categories", notice: 'Reopen time period was successfully updated.'}
          format.json { render json: "/pms/admin/helpdesk_categories", status: 200, location: @complaint_logs}
        end

      end

      private
      # Use callbacks to share common setup or constraints between actions.
      def set_helpdesk_category
        @helpdesk_category = HelpdeskCategory.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def helpdesk_category_params
        params.require(:helpdesk_category).permit(:society_id, :name, :position, :tat, :active, :of_phase, :icon)
      end

      def helpdesk_sub_category_params
        params.require(:helpdesk_sub_category).permit(:name,:active,:helpdesk_category_id)
      end

      def escalation_params
        params.require(:escalation_matrix).permit(:society_id, :cw_id, :p1, :p2, :p3, :p4, :p5, :name, :after_days, :complaint_status_id, :escalate_to_users => [])
      end

      def complaint_status_params
        params.require(:complaint_status).permit(:society_id, :name, :active, :color_code, :position, :fixed_state, :of_phase)
      end

    def complaint_worker_params
      params.require(:complaint_worker).permit(:society_id, :of_atype, :esc_type, :of_phase, :assign, :site_id, :sub_category_id, assign_to: [], category_ids: [],
                                                 escalation_matrix: [
                                                   e1: [:name, :p1, :p2, :p3, :p4, :p5, escalate_to_users: []],
                                                   e2: [:name, :p1, :p2, :p3, :p4, :p5, escalate_to_users: []],
                                                   e3: [:name, :p1, :p2, :p3, :p4, :p5, escalate_to_users: []],
                                                   e4: [:name, :p1, :p2, :p3, :p4, :p5, escalate_to_users: []],
                                                   e5: [:name, :p1, :p2, :p3, :p4, :p5, escalate_to_users: []]
        ])
      end

      def complaint_mode_params
        params.require(:complaint_mode).permit(:society_id, :name, :of_phase, :active)
      end

      def pms_supplier_params
        params.require(:pms_supplier).permit(:first_name, :last_name,:email,:mobile1,:mobile2,:gstin_number,:pan_number,:address,:company_id,:society_id)
      end

      def pms_wing_params
        params.require(:pms_wing).permit(:name,:tower_id,:society_location_id,:active, :building_id, :building_setup_id, :user_id,:company_id)
      end

      def pms_area_params
        params.require(:pms_area).permit(:name, :wing_id,:society_location_id, :building_id,:building_setup_id,:floor_id,:user_id,:company_id,:society_id)
      end

      def society_location_params
        params.require(:society_location).permit(:society_id, :name,:active)
      end

      def aging_rule_params
        params.require(:aging_rule).permit(:rule_type,:rule_unit,:value,:from,:to, :active, :of_phase, :of_atype,:value_in_minute,:from_in_minute,:to_in_minute)
      end
    end
  end
end
