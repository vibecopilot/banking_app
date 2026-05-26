class SoftServicesController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!,  if: :check_user, except: [:print_qr_codes]
  before_action :api_user, except: [:print_qr_codes]
  before_action :set_user, except: [:print_qr_codes]
  before_action :set_soft_service, only: %i[ show edit update destroy softservices_log_show download_log_excel ]

  # GET /soft_services or /soft_services.json
  def index
    include_activities = params[:include_activities] != 'false'
    page = (params[:page] || 1).to_i
    per  = (params[:per_page] || 100).to_i
    per = 100 if per < 10  # Minimum 10 records per page

    # Base query without joins to avoid DISTINCT issues with pagination
    base_query = SoftService
    .where(site_id: @user.current_site_id)
    .ransack(params[:q])
    .result
    .order(created_at: :desc)

    # Card filter: filter by card type clicked
    case params[:card_filter]
    when 'total_services'
      # No additional filter needed, show all services
    when 'with_checklist'
      # Services that have checklists assigned
      service_ids_with_checklist = Checklist
      .where(site_id: @user.current_site_id, ctype: 'soft_service')
      .joins("INNER JOIN activities ON activities.checklist_id = checklists.id")
      .where.not(activities: { soft_service_id: nil })
      .distinct
      .pluck('activities.soft_service_id')
      base_query = base_query.where(id: service_ids_with_checklist)
    when 'tasks'
      # Services that have any tasks
      service_ids_with_tasks = Activity.joins(:checklist)
      .where(checklists: { ctype: 'soft_service' })
      .where.not(soft_service_id: nil)
      .distinct
      .pluck(:soft_service_id)
      base_query = base_query.where(id: service_ids_with_tasks)
    when 'pending'
      # Services that have pending tasks
      service_ids_with_pending = Activity.joins(:checklist)
      .where(checklists: { ctype: 'soft_service' })
      .where(status: 'pending')
      .where.not(soft_service_id: nil)
      .distinct
      .pluck(:soft_service_id)
      base_query = base_query.where(id: service_ids_with_pending)
    when 'completed', 'complete'
      # Services that have completed tasks
      service_ids_with_completed = Activity.joins(:checklist)
      .where(checklists: { ctype: 'soft_service' })
      .where(status: 'complete')
      .where.not(soft_service_id: nil)
      .distinct
      .pluck(:soft_service_id)
      base_query = base_query.where(id: service_ids_with_completed)
    when 'overdue'
      # Services that have overdue tasks
      service_ids_with_overdue = Activity.joins(:checklist)
      .where(checklists: { ctype: 'soft_service' })
      .where(status: 'overdue')
      .where.not(soft_service_id: nil)
      .distinct
      .pluck(:soft_service_id)
      base_query = base_query.where(id: service_ids_with_overdue)
    end

    @total_count = base_query.count
    @current_page = page
    @total_pages = (@total_count.to_f / per).ceil

    if request.format.json?
      # Paginate without includes to avoid issues
      @soft_services = base_query
      .includes(:site, :building, :floor, :user, :qr_code_image, :cron_setting)
      .page(page)
      .per(per)

      # For activities, load separately if needed
      if include_activities
        @soft_services = @soft_services.includes(:activities)
      end


      soft_service_ids = @soft_services.pluck(:id)

      @attachments_by_service = Attachfile
      .where(relation: 'ServiceImaage', relation_id: soft_service_ids)
      .group_by(&:relation_id)

    else
      @soft_services = base_query
      .page(page)
      .per(per)
      .includes(:site, :building, :floor, :user)
    end

    @include_activities = include_activities

    respond_to do |format|
      format.html
      format.json
      format.png do
        soft_service = SoftService.find(params[:id])
        send_file soft_service.qr_code_image.image.path,
          type: 'image/png',
          disposition: 'attachment'
      end
    end
  end

  def export_soft_service
    @soft_services = SoftService.where(site_id: @user.current_site_id).ransack(params[:q]).result.order(created_at: :DESC)
    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = 'attachment; filename="soft_services.xlsx"'
      }
    end
  end

  def overview_count
    soft_services = SoftService
    .where(site_id: @user.current_site_id)
    .ransack(params[:q])
    .result

    soft_service_ids = soft_services.select(:id)

    tasks = Activity.where(soft_service_id: soft_service_ids)

    status_counts = tasks.group(:status).count
    # Example result:
    # { "pending" => 12, "completed" => 25, "overdue" => 5 }

    # Count soft services that have activities with checklists
    services_with_checklist_count = Checklist
    .where(site_id: @user.current_site_id, ctype: 'soft_service')
    .joins("INNER JOIN activities ON activities.checklist_id = checklists.id")
    .where.not(activities: { soft_service_id: nil })
    .distinct
    .count('activities.soft_service_id')

    render json: {
      total_services: soft_services.count,
      total_checklist: services_with_checklist_count,
      total_tasks: tasks.count,
      pending_tasks: status_counts["pending"] || 0,
      completed_tasks: status_counts["completed"] || 0,
      overdue_tasks: status_counts["overdue"] || 0
    }, status: :ok
  end



  def import
    file = params[:file]
    unless file.present?
      redirect_to soft_services_path, alert: "Please Upload an Excel Sheet"
      return
    end

    spreadsheet = Roo::Spreadsheet.open(file.path)
    sheet = spreadsheet.sheet(0)  # 0th sheet

    header = sheet.row(1).map(&:strip) #map and trip for remove extra spaces

    ActiveRecord::Base.transaction do
      (2..sheet.last_row).each do |i|
        row = Hash[header, sheet.row(i).transpose] # 1 row is haders && row 2 = [1, 56, "Cleaning", 10, "2024-01-01"] , headers = ["ID", "Site ID", "Name"]
        # header, sheet.row(i)
        #[
        # ["ID", "Site ID", "Name"],
        # [1, 56, "Cleaning"]
        # ]

        #2 .transpose
        # [
        # ["ID", 1],
        # ["Site ID", 56],
        # ["Name", "Cleaning"]
        # ]

        #3 final hast - Hash[....]
        # {
        # "ID" => 1,
        # "Site Id" => 56,
        # "Name" => "Cleaning"
        # }

        next if row["Name"].blank?

        SoftService.create!(
          site_id: @user.current_site_id,
          building_id: row["Building ID"],
          floor_id: row["Floor ID"],
          unit_id: row["Unit ID"],
          name: row["Name"],
          user_id: row["User ID"],
          generic_info_id: row["Generic Info ID"],
          generic_sub_info_id: row["Generic Sub Info ID"],
          longitude: row["Longitude"],
          latitude: row["Latitude"]
        )

        import_count += 1
      end
    end

    #redirect_to soft_services_path, notice: "Soft Services imported successfully"
    # rescue => e
    #redirect_to soft_services_path, alert: "Import failed: #{e.message}"
    render json: {
      success: true,
      message: "Imported successfully!",
      import_count: import_count,
    }, status: :ok

  rescue Roo::Excelx::FileNotFound
    render json: {
      success: false,
      message: "Invalid or missing Excel file"
    }, status: :unprocessable_entity

  rescue ActiveRecord::RecordInvalid => e
    render json: {
      success: false,
      message: "Validation failed",
      error: e.record.errors.full_messages
    }, status: :unprocessable_entity

  rescue => e
    render json: {
      success: false,
      message: "Error on row #{i}",
      error: e.message
    }, status: :unprocessable_entity
  end


  def print_qr_codes
    # binding.pry
    @soft_services = if params[:soft_service_ids].present?
      SoftService.where(id: params[:soft_service_ids].split(","))
    else
      SiteAsset.where(id: params[:soft_service_ids])
    end
    render pdf: 'qr_codes',
      disposition: 'attachment',
      dpi: 72,
      template: 'soft_services/qr_codes.html',
      # layout: 'layouts/pdf.html.erb',
      formats: :pdf,
      encoding: 'utf8'
    return
  end
  def soft_services_qr_codes
    # binding.pry
    @soft_services = SoftService.where(site_id: @user.current_site_id)
    render pdf: 'soft_services_qr_codes',
      disposition: 'attachment',
      dpi: 72,
      template: 'soft_services/qr_codes.html',
      # layout: 'layouts/pdf.html.erb',
      formats: :pdf,
      encoding: 'utf8'
  end

  # GET /soft_services/1 or /soft_services/1.json
  def show
    respond_to do |format|
      format.html
      format.json
      format.png do
        send_file @soft_service.qr_code_image.image.path, type: 'image/png', disposition: 'attachment'
      end
    end
  end

  def soft_services_dashboard
    site_id = params[:site_id].present? ? params[:site_ids].to_i : @user.current_site_id
    # site_id = @user.current_site_id
    @dashboard = {}
    #SoftService
    @dashboard[:total_services] = SoftService.where(site_id: site_id).count
    @dashboard[:by_building] = SoftService.joins(:building).where(site_id: site_id).group('buildings.name').count
    @dashboard[:by_floor] = SoftService.joins(:floor).where(site_id: site_id).group('floors.name').count
    @dashboard[:by_unit] = SoftService.joins(:unit).where(site_id: site_id).group('units.name').count

    # Checklist
    @dashboard[:checklist] = Checklist.where(site_id: site_id, ctype: "soft_service").count

    #Activity
    @dashboard[:tasks] = Activity.joins(:checklist)
    .where(checklists: { site_id: site_id, ctype: "soft_service" }).count

    @dashboard[:by_status] = Activity.joins(:checklist)
    .where(checklists: { site_id: site_id, ctype: "soft_service" })
    .where("status IN ('overdue', 'complete') OR (status = 'pending' AND DATE(start_time) = ?)", Date.current)
    .group(:status).count

    @dashboard[:by_status_delay] = Activity.joins(:checklist)
    .where(checklists: { site_id: site_id, ctype: "soft_service" })
    .where("status LIKE '%delay%'").count

    # # Calculate the number of tasks not performed
    #   @dashboard[:tasks_not_performed] = Activity.joins(:checklist)
    #                        .where(checklists: { site_id: site_id, ctype: "soft_service" })
    #                        .where(status: ['pending', 'overdue']).count

    #   # Calculate the average of tasks not performed
    #   @dashboard[:avg_tasks_not_performed] = ((@dashboard[:tasks_not_performed].to_f / @dashboard[:tasks]) * 100).round(2) unless @dashboard[:tasks].zero?

    # Calculate the number of tasks performed today
    @dashboard[:tasks_performed_today] = Activity.joins(:checklist)
    .where(checklists: { site_id: site_id, ctype: "soft_service" })
    .where.not(status: ['pending', 'overdue'])
    .where("DATE(start_time) = ?", Date.current)
    .count

    # Calculate the average of tasks performed today
    @dashboard[:avg_tasks_performed_today] = ((@dashboard[:tasks_performed_today].to_f / @dashboard[:tasks]) * 100).round(2) unless @dashboard[:tasks].zero?

    # Calculate the number of tasks due today
    @dashboard[:tasks_due_today] = Activity.joins(:checklist)
    .where(checklists: { site_id: site_id, ctype: "soft_service" })
    .where(status: ['pending', 'overdue'])
    .where("DATE(start_time) = ?", Date.current)
    .count

    # Calculate the number of tasks completed
    @dashboard[:tasks_completed] = Activity.joins(:checklist)
    .where(checklists: { site_id: site_id, ctype: "soft_service" })
    .where(status: 'complete').count

    # Calculate the average of tasks completed
    @dashboard[:avg_tasks_completed] = ((@dashboard[:tasks_completed].to_f / @dashboard[:tasks]) * 100).round(2) unless @dashboard[:tasks].zero?

    render json: @dashboard
  end

  # GET /soft_services/new
  def new
    @soft_service = SoftService.new
  end

  # GET /soft_services/1/edit
  def edit
  end

  # POST /soft_services or /soft_services.json
  def create
    @soft_service = SoftService.new(soft_service_params)

    if params[:soft_service][:unit_id].is_a?(Array)
      @soft_service.unit_id = params[:soft_service][:unit_id].reject(&:blank?).join(',')
    end

    respond_to do |format|
      if @soft_service.save
        if params[:attachfiles].present?
          params[:attachfiles].each do |doc|
            Attachfile.create(image: doc, relation: "ServiceImaage", relation_id: @soft_service.id, active: 1)
          end
        end
        format.html { redirect_to @soft_service, notice: "Soft service was successfully created." }
        format.json { render :show, status: :created, location: @soft_service }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @soft_service.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /soft_services/1 or /soft_services/1.json
  def update
    if params[:soft_service][:unit_id].is_a?(Array)
      params[:soft_service][:unit_id] = params[:soft_service][:unit_id].reject(&:blank?).join(',')
    end
    respond_to do |format|
      if @soft_service.update(soft_service_params)
        if params[:attachfiles].present?
          params[:attachfiles].each do |doc|
            next if doc.to_s == "[object Object]"
            Attachfile.create(image: doc, relation: "ServiceImaage", relation_id: @soft_service.id, active: 1)
          end
        end
        format.html { redirect_to @soft_service, notice: "Soft service was successfully updated." }
        format.json { render :show, status: :ok, location: @soft_service }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @soft_service.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /soft_services/1 or /soft_services/1.json
  def destroy
    @soft_service.destroy
    respond_to do |format|
      format.html { redirect_to soft_services_url, notice: "Soft service was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def softservices_log_show
    @activities = Activity.where(soft_service_id: @soft_service.id)
    .includes(:checklist, :submissions)
    .where("Date(start_time) <= ?", Date.today)
    .order(start_time: :DESC)
    respond_to do |format|
      format.html
      format.json { render json: soft_service_ppm_data }
    end
  end


  def activities_for_soft_service
    soft_service = SoftService.find(params[:id])
    activities = soft_service.activities
    .order(start_time: :desc)
    .limit(250)
    .pluck(:id, :asset_id, :checklist_id, :start_time, :end_time, :status, :assigned_to, :soft_service_id, :patrolling_id, :group_id)

    render json: activities.map { |a|
      {
        id: a[0],
        asset_id: a[1],
        checklist_id: a[2],
        start_time: a[3],
        end_time: a[4],
        status: a[5],
        assigned_to: a[6],
        soft_service_id: a[7],
        patrolling_id: a[8],
        group_id: a[9]
      }
    }
  end





  def download_log_excel
    @activities = Activity.where(soft_service_id: @soft_service.id)
    .includes(:checklist, :submissions, :user)
    .where("Date(start_time) <= ?", Date.today)
    .order(start_time: :DESC)

    @excel_log_data = prepare_excel_log_data

    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = 'attachment; filename="soft_service_log.xlsx"'
        render xlsx: 'soft_service_log', filename: "soft_service_log.xlsx"
      }
    end
  end

  def download_all_log_excel
    @soft_services = SoftService.where(site_id: @user.current_site_id)
    @excel_log_data = @soft_services.flat_map do |soft_service|
      activities = soft_service.activities
      .includes(:checklist, :submissions, :user)
      .where("Date(start_time) <= ?", Date.today)
      .order(start_time: :DESC)
      prepare_excel_all_log_data(activities, soft_service)
    end

    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = 'attachment; filename="all_soft_service_logs.xlsx"'
        render xlsx: 'all_soft_service_logs', filename: "all_soft_service_logs.xlsx"
      }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_soft_service
    @soft_service = SoftService.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def soft_service_params
    params.require(:soft_service).permit(:site_id, :building_id, :floor_id, :name, :user_id, :unit_id, :generic_info_id, :generic_sub_info_id, :longitude, :latitude)
  end

  def prepare_excel_all_log_data(activities, soft_service)
    activities.map do |activity|
      submissions = activity.submissions.includes(:question)
      {
        soft_service_name: soft_service.name,
        site_name: soft_service.site&.name,
        site_id: soft_service.site_id,
        building_name: soft_service.building&.name,
        building_id: soft_service.building_id,
        floor_name: soft_service.floor&.name,
        floor_id: soft_service.floor_id,
        unit_name: soft_service.unit&.name,
        unit_id: soft_service.unit_id,
        activity_id: activity.id,
        start_time: activity.start_time&.strftime("%Y-%m-%d %H:%M:%S"),
        end_time: activity.updated_at&.strftime("%Y-%m-%d %H:%M:%S"),
        status: activity.status,
        checklist_name: activity.checklist&.name,
        checklist_frequency: activity.checklist&.frequency,
        checklist_start_date: activity.checklist&.start_date,
        checklist_end_date: activity.checklist&.end_date,
        checklist_occurs: activity.checklist&.occurs,
        checklist_type: activity.checklist&.ctype,
        performed_by: activity.user&.full_name || "Unassigned",
        assigned_to: User.find_by(id: activity.assigned_to)&.full_name || "Unassigned",
        total_questions_performed: activity.submissions.count,
        submissions: submissions.map do |submission|
          {
            question: submission.question&.name,
            answer: submission.value,
            comment: submission.comment,
            updated_at: submission.updated_at&.strftime("%Y-%m-%d %H:%M:%S")
          }
        end
      }
    end
  end

  def prepare_excel_log_data
    @activities.map do |activity|
      {
        start_time: activity.start_time&.strftime("%Y-%m-%d %H:%M:%S"),
        end_time: activity.updated_at&.strftime("%Y-%m-%d %H:%M:%S"),
        status: activity.status,
        assigned_name: activity.user&.full_name || "Unassigned",
        checklist_name: activity.checklist&.name,
        frequency: activity.checklist&.frequency,
        total_questions: activity.submissions.count,
        submissions: activity.submissions.map do |submission|
          {
            question_name: submission.question&.name,
            value: submission.value
          }
        end
      }
    end
  end

  def soft_service_ppm_data
    {
      soft_service: {
        id: @soft_service.id,
        name: @soft_service.name,
        site_id: @soft_service.site_id,
        building_id: @soft_service.building_id,
        floor_id: @soft_service.floor_id,
        unit_id: @soft_service.unit_id,
        generic_info_id: @soft_service.generic_info_id,
        generic_sub_info_id: @soft_service.generic_sub_info_id
      },
      activities: @activities.map do |activity|
        {
          id: activity.id,
          start_time: activity.start_time,
          end_time: activity.end_time,
          status: activity.status,
          assigned_to: activity.assigned_to,
          assigned_name: assigned_to_name(activity.assigned_to),
          checklist: activity.checklist ? {
            id: activity.checklist.id,
            name: activity.checklist.name,
            frequency: activity.checklist.frequency,
            ctype: activity.checklist.ctype
          } : nil,
          activity_log: {
            submissions: activity.submissions.map do |submission|
              question = Question.find_by(id: submission.question_id)
              {
                id: submission.id,
                question: question ? {
                  id: question.id,
                  name: question.name,
                  qtype: question.qtype,
                  options: [question.option1, question.option2, question.option3, question.option4].compact
                } : nil,
                value: submission.value,
                updated_at: submission.updated_at,
                question_attachments: attachments_for_question(submission)
              }
            end
          },
          comment: activity.submissions.first&.comment
        }
      end
    }
  end

  def attachments_for_question(submission)
    attachments = Attachfile.where("relation LIKE ? and relation_id = ?", "Question-#{submission.question_id}", submission.id)
    attachments.map do |doc|
      {
        id: doc.id,
        relation: doc.relation,
        relation_id: doc.relation_id,
        document: doc.document_url
      }
    end
  end

  def assigned_to_name(user_id)
    user = User.find_by(id: user_id)
    user ? user.full_name : "Unassigned"
  end

end
