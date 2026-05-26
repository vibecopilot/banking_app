class MomDetailsController < ApplicationController
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_mom_detail, only: %i[ show edit update destroy ]

  # GET /mom_details or /mom_details.json
  def index
    @mom_details = MomDetail.where(site_id: @user.current_site_id)
  end

  # GET /mom_details/1 or /mom_details/1.json
  def show
  end

  # GET /mom_details/new
  def new
    @mom_detail = MomDetail.new
  end

  # GET /mom_details/1/edit
  def edit
  end

  # POST /mom_details or /mom_details.json
  def create
    @mom_detail = MomDetail.new(mom_detail_params)

    respond_to do |format|
      if @mom_detail.save
        format.html { redirect_to @mom_detail, notice: "Mom detail was successfully created." }
        format.json { render :show, status: :created, location: @mom_detail }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @mom_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mom_details/1 or /mom_details/1.json
  def update
    respond_to do |format|
      if @mom_detail.update(mom_detail_params)
        format.html { redirect_to @mom_detail, notice: "Mom detail was successfully updated." }
        format.json { render :show, status: :ok, location: @mom_detail }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @mom_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mom_details/1 or /mom_details/1.json
  def destroy
    @mom_detail.destroy
    respond_to do |format|
      format.html { redirect_to mom_details_url, notice: "Mom detail was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mom_detail
      @mom_detail = MomDetail.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def mom_detail_params
      params.require(:mom_detail).permit(:title, :meeting_date, :created_by_id, :active, :company_tag_name,
      mom_tasks_attributes: [:id, :description, :responsible_person_id, :target_date, :responsible_person_email, :responsible_person_type, :responsible_person_name, :company_tag_id, :_destroy],
      mom_attendees_attributes: [:id, :name, :organization, :role, :email, :company_tag_name, :attendees_id, :attendees_type, :_destroy])
    end
end
