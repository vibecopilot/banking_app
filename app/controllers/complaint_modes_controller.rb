class ComplaintModesController < ApplicationController
  def index
	 @complaint_modes = ComplaintMode.ransack(params[:q]).result
	 render json: @complaint_modes
  end


  # POST /complaint_modes
  def create
    @complaint_mode = ComplaintMode.new(complaint_mode_params)

    if @complaint_mode.save
      render json: @complaint_mode, status: :created
    else
      render json: @complaint_mode.errors, status: :unprocessable_entity
    end
  end

  # GET /complaint_modes/:id/edit
  def edit
    @complaint_mode = ComplaintMode.find(params[:id])
    render json: @complaint_mode
  end

  private

  # Only allow a list of trusted parameters through.
  def complaint_mode_params
    params.require(:complaint_mode).permit(:site_id, :name, :active, :of_phase, :of_atype)
  end
end
