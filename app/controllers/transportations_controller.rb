class TransportationsController < ApplicationController
   include UserExt
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_transportation, only: %i[ show edit update destroy ]

  # GET /transportations or /transportations.json
  def index
    # @current_user = @current_user || @user

    @q =  if @user.user_type == "pms_admin"
          Transportation.where(site_id: @user.current_site_id).ransack(params[:q])
          else 
          Transportation.where(created_by_id: @user.id).ransack(params[:q])
        end
    @transportations = @q.result(distinct: true) # Apply the filter
    render json: @transportations
  end

  # GET /transportations/1 or /transportations/1.json
  def show
  end

  # GET /transportations/new
  def new
    @transportation = Transportation.new
  end

  # GET /transportations/1/edit
  def edit
  end

  # POST /transportations or /transportations.json
  def create
    @transportation = Transportation.new(transportation_params)

    respond_to do |format|
      if @transportation.save
        if params[:attachments].present? 
          params[:attachments].each do |doc|
            Attachfile.create(image: doc, relation: "Transportation", relation_id: @transportation.id, active: 1)
          end
        end
        format.html { redirect_to @transportation, notice: "Transportation was successfully created." }
        format.json { render :show, status: :created, location: @transportation }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @transportation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transportations/1 or /transportations/1.json
  def update
    respond_to do |format|
      if @transportation.update(transportation_params)
        format.html { redirect_to @transportation, notice: "Transportation was successfully updated." }
        format.json { render :show, status: :ok, location: @transportation }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @transportation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transportations/1 or /transportations/1.json
  def destroy
    @transportation.destroy
    respond_to do |format|
      format.html { redirect_to transportations_url, notice: "Transportation was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transportation
      @transportation = Transportation.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def transportation_params
      params.require(:transportation).permit(:on_behalf_of, :pickup_location, :dropoff_location, :date, :time, :no_of_passengers, :additional_note, :transportation_type , :user_id, :created_by_id)
    end
end
