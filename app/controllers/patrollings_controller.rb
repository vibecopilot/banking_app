class PatrollingsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_patrolling, only: %i[ show edit update destroy ]
  # before_action :authenticate_user!, except: [:index, :show]

  # GET /patrollings or /patrollings.json
def index
  base_includes = [:site, :building, :floor, :unit, :qr_code_image]
  base_includes << :activities if params[:include_activities] == 'true'
  base_includes << :patrolling_histories if params[:include_histories] == 'true'

  base_scope = Patrolling.where(site_id: @user.current_site_id)
  @q = base_scope.ransack(params[:q])

  @patrollings = @q.result
                   .includes(base_includes)
                   .order(created_at: :desc)
                   .page(params[:page])
                   .per((params[:per_page] || 100).to_i)

  respond_to do |format|
    format.html
    format.json
  end
end



  # GET /patrollings/1 or /patrollings/1.json
  def show
    @patrolling_histories = @patrolling.patrolling_histories.order(:expected_time)
  end

  # GET /patrollings/new
  def new
    @patrolling = Patrolling.new
  end


  # GET /patrollings/1/edit
  def edit
  end

  # POST /patrollings or /patrollings.json
  def create
    @patrolling = Patrolling.new(patrolling_params.merge(site_id: @user.current_site_id))

    respond_to do |format|
      if @patrolling.save
        format.html { redirect_to @patrolling, notice: "Patrolling was successfully created." }
        format.json { render :show, status: :created, location: @patrolling }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @patrolling.errors, status: :unprocessable_entity }
      end
    end
  end

   # POST /patrollings/:id/scan
  def scan
    @patrolling = Patrolling.find_by(id: params[:id])
    @patrolling_history = PatrollingHistory.find_by(id: params[:patrolling_history_id])

    if @patrolling.nil?
      render json: { error: "Patrolling record not found" }, status: :not_found
      return
    end

    if @patrolling_history.nil? || @patrolling.id != @patrolling_history.patrolling_id
      render json: { error: "QR Code scanned is not valid" }, status: :unprocessable_entity
      return
    end

    unless @user.present?
      render json: { error: "User not authenticated" }, status: :unauthorized
      return
    end

    user_id = @user.id
    current_time = Time.current

    if @patrolling_history.user_id.nil?
      if @patrolling_history.update(user_id: user_id, actual_time: current_time)
        render json: { message: "Scan recorded successfully for #{@patrolling_history.expected_time&.strftime('%H:%M') || 'N/A'}. Patrolling is Started" }, status: :ok
      else
        render json: { error: @patrolling_history.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { message: "This patrol time has already been recorded" }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /patrollings/1 or /patrollings/1.json
  def update
    respond_to do |format|
      if @patrolling.update(patrolling_params)

        CreatePatrollingHistoriesJob.perform_later(@patrolling.id)

        format.html { redirect_to @patrolling, notice: "Patrolling was successfully updated." }
        format.json { render :show, status: :ok, location: @patrolling }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @patrolling.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @patrolling.destroy
    respond_to do |format|
      format.html { redirect_to patrollings_url, notice: "Patrolling was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  def set_patrolling
    @patrolling = Patrolling.find(params[:id])
  end

  def patrolling_params
    params.require(:patrolling).permit(:patrolling_name, :building_id, :site_id, :floor_id, :unit_id, :longitude, :latitude, :start_date, :end_date, :start_time, :end_time, :time_intervals, specific_times: [])
  end
end
