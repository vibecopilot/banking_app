class PatrollingHistoriesController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user 
  before_action :set_user
  before_action :set_patrolling_history, only: %i[ show edit update destroy ]

    # GET /patrolling_histories or /patrolling_histories.json
 def index
  # Allow up to 100 records per page
  per_page = [params[:per_page].to_i, 100].min
  per_page = 10 if per_page <= 0
  page = [params[:page].to_i, 1].max
  offset = (page - 1) * per_page

  @patrolling_histories = PatrollingHistory
    .includes(:user, patrolling: [:building, :floor, :unit])
    .joins(:patrolling)
    .where(patrollings: { site_id: @user.current_site_id })
    .order(created_at: :desc)
    .limit(per_page)
    .offset(offset)
end


  # GET /patrolling_histories/1 or /patrolling_histories/1.json
  def show
  end

  # GET /patrolling_histories/new
  def new
  @patrolling_history = PatrollingHistory.new
  end

  # GET /patrolling_histories/1/edit
  def edit
  end

  # POST /patrolling_histories or /patrolling_histories.json
  def create
    @patrolling_history = PatrollingHistory.new(patrolling_history_params)

    respond_to do |format|
      if @patrolling_history.save
        format.html { redirect_to @patrolling_history, notice: "Patrolling history was successfully created." }
        format.json { render :show, status: :created, location: @patrolling_history }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @patrolling_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /patrolling_histories/1 or /patrolling_histories/1.json
  def update
    respond_to do |format|
      if @patrolling_history.update(patrolling_history_params)
        @patrolling_history.actual_time = DateTime.current
        if params[:attachment].present? 
            Attachfile.create(image: params[:attachment], relation: "PatrollingHistory", relation_id: @patrolling_history.id, active: 1)
        end
        format.html { redirect_to @patrolling_history, notice: "Patrolling history was successfully updated." }
        format.json { render :show, status: :ok, location: @patrolling_history }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @patrolling_history.errors, status: :unprocessable_entity }
      end
    end
  end

 def export
  site_id = @user.current_site_id.presence || params[:site_id]

  # Step 1: Get all patrolling IDs for the site
  patrolling_ids = Patrolling.where(site_id: site_id).pluck(:id)

  # Step 2: For each patrolling, get top 100 histories (in batches)
  limited_history_ids = patrolling_ids.flat_map do |pid|
    PatrollingHistory.where(patrolling_id: pid)
                     .order(expected_time: :desc)
                     .limit(100)
                     .pluck(:id)
  end

  # Step 3: Fetch full history records with eager loading
  limited_histories = PatrollingHistory
    .includes(:user, patrolling: [:building, :floor, :unit])
    .where(id: limited_history_ids)
    .order(expected_time: :desc)

  if limited_histories.blank?
    render json: { error: "No records found for the given site." }, status: :not_found
    return
  end

  # Step 4: Load all related images in one query
  attachments = Attachfile
    .where(relation: "PatrollingHistory", relation_id: limited_histories.map(&:id))
    .group_by(&:relation_id)

  # Step 5: Create Excel file
  package = Axlsx::Package.new
  workbook = package.workbook

  workbook.add_worksheet(name: "Patrolling Report") do |sheet|
    sheet.add_row [
      "ID", "User", "Building", "Floor", "Unit",
      "Expected Time", "Actual Time", "Longitude", "Latitude",
      "Comment", "Created At", "Updated At", "Image Links"
    ]

    limited_histories.each do |ph|
      building = ph.patrolling&.building&.name
      floor    = ph.patrolling&.floor&.name
      unit     = ph.patrolling&.unit&.name
      image_links = (attachments[ph.id] || []).map { |img| "https://app.myciti.life/#{img.document_url}" }

      sheet.add_row [
        ph.id,
        ph.user&.full_name || "N/A",
        building,
        floor,
        unit,
        ph.expected_time&.strftime("%d/%m/%Y %I:%M %p"),
        ph.actual_time&.strftime("%d/%m/%Y %I:%M %p"),
        ph.longitude,
        ph.latitude,
        ph.comment,
        ph.created_at.strftime("%d/%m/%Y %I:%M %p"),
        ph.updated_at.strftime("%d/%m/%Y %I:%M %p"),
        image_links.join(', ')
      ]
    end
  end

  filename = "patrolling_report_site_#{site_id}_#{Time.now.strftime('%Y%m%d_%H%M%S')}.xlsx"
  send_data package.to_stream.read,
            filename: filename,
            type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
end


  # DELETE /patrolling_histories/1 or /patrolling_histories/1.json
  def destroy
    @patrolling_history.destroy
    respond_to do |format|
      format.html { redirect_to patrolling_histories_url, notice: "Patrolling history was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_patrolling_history
      @patrolling_history = PatrollingHistory.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def patrolling_history_params
      params.require(:patrolling_history).permit(:user_id, :patrolling_id, :expected_time, :actual_time, :longitude, :latitude,:comment)
    end
end
