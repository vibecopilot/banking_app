module Pms
  module Manage
    class ComplaintsController < ApplicationController
      include UserExt
      before_action :authenticate_user!, if: :check_user
      before_action :api_user
      before_action :set_user
      before_action :set_complaint, only: [:show, :edit, :update, :destroy, :send_vendor_mail]
      layout 'basic'
      def index
        if params[:q].present? && params[:q][:date_range].present?
          @date_range = params[:q][:date_range].scan(/\d{4}-\d{2}-\d{2}/)
          if @date_range.size == 2
            params[:q][:created_at_gteq] = Date.strptime(@date_range[0], "%Y-%m-%d")
            params[:q][:created_at_lteq] = Date.strptime(@date_range[1], "%Y-%m-%d")
          end
        end

        site_id = @user.current_site_id

        base_scope =
        Complaint.left_joins(
          :category_type,
          :sub_category,
          :helpdesk_sub_category,
          :complaint_status,
          :tower,
          :floor,
          :unit,
          :site,
          :user
        ).joins(
          "LEFT JOIN users assigned_users ON assigned_users.id = complaints.assigned_to"
        ).includes(
          :user,
          :assigned_to_user,
          :complaint_status,
          :helpdesk_category,
          :helpdesk_sub_category,
          { unit: [:floor, :building, :site] },
          { complaint_logs: [:complaint_comments] },
          :attachments
        ).where(complaints: { site_id: site_id })

        filtered_scope =
        if @user.user_type == "pms_technician"
          base_scope
          .ransack(params[:q]).result
          .where("complaints.assigned_to = ? OR complaints.id_user = ?", @user.id, @user.id)
        else
          base_scope
          .ransack(params[:q]).result
        end

        # Build dashboard-style counts from the filtered (unpaginated) scope
        status_counts = filtered_scope
        .where("complaint_statuses.name IS NOT NULL")
        .group("complaint_statuses.name")
        .count
        type_counts = filtered_scope
        .where("TRIM(COALESCE(complaints.complaint_type, '')) != ''")
        .group("complaints.complaint_type")
        .count

        @filtered_counts = {
          total: filtered_scope.count,
          by_status: status_counts,
          by_type: type_counts
        }

        @complaints = filtered_scope
        .order(id: :desc)
        .page(params[:page])
        .per(params[:per_page] || 10)

        if params[:format] == "json"
          render "pms/manage/complaints/user_helpdesk"
        else
          render layout: "basic"
        end
      end



      def edit
        data = @complaint.as_json
        if @complaint.user
          data["created_by_name"] = @complaint.user.full_name
        end
        if @complaint.assigned_to_user
          data["assigned_to_id"] = @complaint.assigned_to
        end
        render json: data
      end

      def update
        if @complaint.update(complaint_params)
          render json: @complaint
        else
          render json: { errors: @complaint.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def create
        @complaint = Complaint.new(complaint_params.merge(id_user: @user.id, site_id: @user.current_site_id, created_by: @user.id))
        respond_to do |format|
          if @complaint.save
            if params[:documents].present?
              params[:documents].each do |doc|
                Attachfile.create!(image: doc, relation: "Complaint", relation_id: @complaint.id, active: 1)
              end
            end
            if params[:attachments].present?
              params[:attachments].each do |doc|
                Attachfile.create(image: doc, relation: "Complaint", relation_id: @complaint.id, active: 1)
              end
            end
            format.html { redirect_to "/pms/admin/complaints/#{@complaint.id}", notice: "Complaint was successfully created." }
            format.json { render "pms/manage/complaints/show", status: :created }
          else
            format.html { render :new }
            format.json { render json: @complaint.errors, status: :unprocessable_entity }
          end
        end
      end

      # GET /complaints/1
      # GET /complaints/1.json
      def show
        @complaint_modes = ComplaintMode.pms.active.where(society_id: @user.company_id)
        @pms_suppliers = Pms::Supplier.where(company_id: @user.company_id)
        if params["format"] == "json"
          render "pms/manage/complaints/show"
        end
      end

      # def export_complaints
      #   if @user.user_type == "pms_technician"
      #     @complaints = Complaint.ransack(user_id_or_assigned_to_eq: @user.id).result.ransack(params[:q]).result.order("id DESC")
      #   else
      #     @complaints = Complaint.where(site_id: @user.current_site_id).ransack(params[:q]).result.order("id DESC")
      #   end

      #   respond_to do |format|
      #     format.xlsx {
      #       response.headers['Content-Disposition'] = 'attachment; filename="complaints.xlsx"'
      #     }
      #   end
      # end
      def export_complaints
        if @user.user_type == "pms_technician"
          base_query = Complaint.where(
            "complaints.user_id = :id OR complaints.assigned_to = :id",
            id: @user.id
          )
        else
          base_query = Complaint.left_joins(
            :category_type,
            :sub_category,
            :helpdesk_sub_category,
            :complaint_status,
            :tower,
            :floor,
            :unit,
            :site,
            :user
          ).joins(
            "LEFT JOIN users assigned_users ON assigned_users.id = complaints.assigned_to"
          ).includes(
            :user,
            :assigned_to_user,
            :complaint_status,
            :helpdesk_category,
            :helpdesk_sub_category,
            { unit: [:floor, :building, :site] },
            { complaint_logs: [:complaint_comments] },
            :attachments
          ).where(site_id: @user.current_site_id)
        end

        @q = base_query.ransack(params[:q])
        @complaints = @q.result

        start_date_param = params[:start_date].presence || params[:start_date_eq].presence
        end_date_param   = params[:end_date].presence   || params[:end_date_eq].presence

        if start_date_param.present? && end_date_param.present?
          start_date = Date.parse(start_date_param).beginning_of_day
          end_date   = Date.parse(end_date_param).end_of_day
          @complaints = @complaints.where(created_at: start_date..end_date)

        elsif start_date_param.present?
          start_date = Date.parse(start_date_param).beginning_of_day
          @complaints = @complaints.where('complaints.created_at >= ?', start_date)

        elsif end_date_param.present?
          end_date = Date.parse(end_date_param).end_of_day
          @complaints = @complaints.where('complaints.created_at <= ?', end_date)
        end

        @complaints = @complaints.order(id: :desc)

        respond_to do |format|
          format.xlsx do
            response.headers['Content-Disposition'] = 'attachment; filename="complaints.xlsx"'
          end
        end
      end

      # Changes
      PER_PAGE_DASHBOARD = 10

      # GET complaints_dashboard
      # By default returns only counts for all groups.
      # Pass count_type (e.g. "status", "type", "category", etc.) to get
      # paginated records (10 per page) for that specific group.
      # Optional: count_value to filter a specific value within the group,
      #           record_page for pagination page number.
      def complaints_dashboard
        site_id = params[:site_id].present? ? params[:site_id].to_i : @user.current_site_id
        # If pagination parameters are present (without dashboard-specific params),
        # return filtered records list instead of dashboard counts
        if (params[:page].present? || params[:per_page].present?) && params[:count_type].blank?
          return complaints_dashboard_filtered
        end
        # Base scope with date filtering if provided
        base_scope = Complaint.where(site_id: site_id).includes(
          :complaint_status, :category_type, :unit, :user, :assigned_to_user
        )
        # Apply ransack filters if present (e.g. building, floor, unit filters)
        if params[:q].present?
          base_scope = base_scope.ransack(params[:q]).result
        end
        # Apply date filtering if start_date_eq and end_date_eq are present
        if params[:start_date_eq].present? && params[:end_date_eq].present?
          start_date = Date.parse(params[:start_date_eq]).beginning_of_day
          end_date = Date.parse(params[:end_date_eq]).end_of_day
          base_scope = base_scope.where(created_at: start_date..end_date)
        elsif params[:start_date_eq].present?
          start_date = Date.parse(params[:start_date_eq]).beginning_of_day
          base_scope = base_scope.where('created_at >= ?', start_date)
        elsif params[:end_date_eq].present?
          end_date = Date.parse(params[:end_date_eq]).end_of_day
          base_scope = base_scope.where('created_at <= ?', end_date)
        end

        count_type = params[:count_type].to_s.presence
        # Specific value within the group to show records for
        count_value = params[:count_value].to_s.presence
        record_page = (params[:record_page].presence || 1).to_i

        @complaints = {}
        @complaints[:total] = base_scope.count

        #------ by_all -------------
        all_counts = { 'total_recs' => base_scope.count }
        @complaints[:all] = build_group_with_records(
          base_scope,
          'total_recs',
          all_counts,
          ->(scope, _val) { scope }, # no filtering, return all
          count_type,
          count_value,
          record_page
        )
        # --- by_status ---
        status_counts = base_scope.joins(:complaint_status).group('complaint_statuses.name').count
        @complaints[:by_status] = build_group_with_records(
          base_scope, 'status', status_counts,
          ->(scope, name) { scope.joins(:complaint_status).where(complaint_statuses: { name: name }) },
          count_type, count_value, record_page
        )

        # --- by_type ---
        type_scope = base_scope.where("TRIM(complaint_type) != ''")
        type_counts = type_scope.group('complaints.complaint_type').count
        @complaints[:by_type] = build_group_with_records(
          base_scope, 'type', type_counts,
          ->(scope, val) { scope.where("TRIM(complaints.complaint_type) = ?", val.to_s) },
          count_type, count_value, record_page
        )

        # --- by_category ---
        cat_counts = base_scope.joins(:category_type).group('helpdesk_categories.name').count
        @complaints[:by_category] = build_group_with_records(
          base_scope, 'category', cat_counts,
          ->(scope, name) { scope.joins(:category_type).where(helpdesk_categories: { name: name }) },
          count_type, count_value, record_page
        )
        # --- by_issue_type ---
        issue_counts = base_scope.group('complaints.issue_type_id').count
        @complaints[:by_issue_type] = build_group_with_records(
          base_scope, 'issue_type', issue_counts,
          ->(scope, val) {
            if val.nil? || val.to_s == '' || val.to_s.downcase == 'null'
              scope.where(issue_type_id: nil)
            else
              scope.where(issue_type_id: val)
            end
          },
          count_type, count_value, record_page,
          key_transform: ->(k) { k.nil? ? 'N/A' : k.to_s }
        )

        # --- by_resolution_breached ---
        res_counts = base_scope.group('complaints.resolution_breached').count
        @complaints[:by_resolution_breached] = build_group_with_records(
          base_scope, 'resolution_breached', res_counts,
          ->(scope, val) {
            scope.where(resolution_breached: val == true || val.to_s =~ /^(true|1|yes)$/i)
          },
          count_type, count_value, record_page,
          key_transform: ->(k) { k.nil? ? 'N/A' : (k ? 'Yes' : 'No') }
        )

        # --- by_response_breached ---
        resp_counts = base_scope.group('complaints.response_breached').count
        @complaints[:by_response_breached] = build_group_with_records(
          base_scope, 'response_breached', resp_counts,
          ->(scope, val) {
            scope.where(response_breached: val == true || val.to_s =~ /^(true|1|yes)$/i)
          },
          count_type, count_value, record_page,
          key_transform: ->(k) { k.nil? ? 'N/A' : (k ? 'Yes' : 'No') }
        )

        # --- by_floor ---
        floor_counts = base_scope.joins(unit: :floor).group('floors.name').count
        @complaints[:by_floor] = build_group_with_records(
          base_scope, 'floor', floor_counts,
          ->(scope, name) { scope.joins(unit: :floor).where(floors: { name: name }) },
          count_type, count_value, record_page
        )

        # --- by_priority ---
        priority_counts = base_scope.group('complaints.priority').count
        @complaints[:by_priority] = build_group_with_records(
          base_scope, 'priority', priority_counts,
          ->(scope, val) { scope.where(complaints: { priority: val }) },
          count_type, count_value, record_page,
          key_transform: ->(k) { k.nil? || k.to_s.blank? ? 'N/A' : k.to_s }
        )

        # --- by_unit ---
        unit_counts = base_scope.joins(:unit).group('units.name').count
        @complaints[:by_unit] = build_group_with_records(
          base_scope, 'unit', unit_counts,
          ->(scope, name) { scope.joins(:unit).where(units: { name: name }) },
          count_type, count_value, record_page
        )

        # --- by_tenant ---
        tenant_counts = base_scope
        .joins("LEFT JOIN users AS tenant_users ON tenant_users.id = complaints.id_user")
        .group("TRIM(CONCAT(COALESCE(tenant_users.firstname,''), ' ', COALESCE(tenant_users.lastname,'')))")
        .count
        @complaints[:by_tenant] = build_group_with_records(
          base_scope, 'tenant', tenant_counts,
          ->(scope, name) {
            scope.joins("LEFT JOIN users AS tenant_users ON tenant_users.id = complaints.id_user")
            .where("TRIM(CONCAT(COALESCE(tenant_users.firstname,''), ' ', COALESCE(tenant_users.lastname,''))) = ?", name)
          },
          count_type, count_value, record_page,
          key_transform: ->(k) { k.to_s.strip.presence || 'Unknown' }
        )

        render json: @complaints
      end

      def complaints_drill
        respond_to do |format|
          format.json { render json: { message: "drill" } }
          format.html
        end
      end

      def ticket_list
        complaints = Complaint.where(site_id: @user.current_site_id)
                              .select(:id, :ticket_number, :heading)
                              .order(id: :desc)

        render json: {
          complaints: complaints.map { |c|
            { id: c.id, ticketNumber: c.ticket_number, heading: c.heading }
          }
        }
      end

      private
      # Use callbacs to share common setup or constraints between actions.
      def set_complaint
        @complaint = Complaint.find(params[:id])
      end

      # By default returns flat counts: { "Pending" => 154, "Closed" => 5, ... }
      # When count_type matches this filter_type AND count_value matches a key,
      # that key expands to include paginated records.
      def build_group_with_records(base_scope, filter_type, counts_hash, scope_filter_proc,
                                   count_type, count_value, record_page,
                                   key_transform: ->(k) { k.to_s })
        result = {}
        load_records = (count_type == filter_type)

        counts_hash.each do |key, count|
          display_key = key_transform.call(key)

          # Only fetch records for the specific value the client requested
          if load_records && count_value.present? && count_value == display_key
            filtered_scope = scope_filter_proc.call(base_scope, key)
            paginated = filtered_scope.order(id: :desc).page(record_page).per(PER_PAGE_DASHBOARD)
            records = paginated.map { |c| complaint_record_details(c) }
            result[display_key] = {
              count: count,
              records: records,
              total_pages: paginated.total_pages,
              current_page: paginated.current_page,
              per_page: PER_PAGE_DASHBOARD
            }
          else
            # Flat count only
            result[display_key] = count
          end
        end
        result
      end

      def complaint_record_details(c)
        {
          id: c.id,
          ticket_number: c.ticket_number,
          heading: c.heading,
          text: c.text&.truncate(100),
          priority: c.priority,
          complaint_type: c.complaint_type,
          status: c.complaint_status&.name,
          status_color: c.complaint_status&.color_code,
          category: c.category_type&.name,
          unit_name: c.unit&.name,
          unit_id: c.unit_id,
          floor_name: c.unit&.floor&.name,
          building_name: c.unit&.building&.name,
          created_at: c.created_at,
          updated_at: c.updated_at,
          created_by: c.user&.full_name,
          assigned_to: c.assigned_to_user&.full_name,
          response_breached: c.response_breached,
          resolution_breached: c.resolution_breached
        }
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def complaint_issue_types
        @issue_types = IssueType.where(active: [nil, 1])
        render json: @issue_types.map { |t| { id: t.id, name: t.name } }
      end

      def complaint_params
        if params[:complaint].present?
          params.require(:complaint).permit(:id_society, :id_user, :heading, :text, :active, :action, :IsDelete, :flat_number, :issue_type, :issue_status, :category_type_id, :sub_category_id,:is_urgent, :updated_by, :user_society_id, :issue_type_id, :assigned_to, :complaint_type, :priority, :urgency, :ticket_number, :on_behalf_of, :of_phase, :site_id, :dept_id, :unit_id, :society_staff_type, :reference_number, :asset_id, :territory_manager_id, :additional_notes, :impact, :impact_details, :root_cause, :severity, :service_type, :solution, :workaround, :post_incident_action, :mode, :ticket_type, :group_name, :items, :emails_to_notify, :due_date_by, :response_due_date, :requester_phone, :requester_department, :requester_job, :scheduled_start_time, :scheduled_end_time, :responded_at, :closure_date, :response_time, :resolution_time, :item_ids => [] ).tap do |whitelisted|
            # Explicitly reject file upload parameters that should be handled separately
            whitelisted.delete(:attachments)
            whitelisted.delete(:documents)
          end
        else
          params.permit(:id_society, :id_user, :heading, :text, :active, :action, :IsDelete, :flat_number, :issue_type, :issue_status, :category_type_id, :sub_category_id, :is_urgent, :updated_by, :user_society_id, :issue_type_id, :assigned_to, :complaint_type, :priority, :urgency, :ticket_number, :on_behalf_of, :of_phase, :site_id, :dept_id, :unit_id, :society_staff_type, :reference_number, :asset_id, :territory_manager_id, :additional_notes, :impact, :impact_details, :root_cause, :severity, :service_type, :solution, :workaround, :post_incident_action, :mode, :ticket_type, :group_name, :items, :emails_to_notify, :due_date_by, :response_due_date, :requester_phone, :requester_department, :requester_job, :scheduled_start_time, :scheduled_end_time, :responded_at, :closure_date, :response_time, :resolution_time, :item_ids => [] ).tap do |whitelisted|
            # Explicitly reject file upload parameters that should be handled separately
            whitelisted.delete(:attachments)
            whitelisted.delete(:documents)
          end
        end
      end
    end
  end
end
