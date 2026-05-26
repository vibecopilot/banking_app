class JobSheetsController < ApplicationController
  include UserExt
  protect_from_forgery with: :null_session
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_job_sheet, only: %i[ show update destroy check_in check_out ]

  def index
    @job_sheets = JobSheet.for_site(@user.current_site_id)
                          .includes(:ticket)
                          .order(created_at: :desc)
    render json: @job_sheets.map { |js| job_sheet_json(js) }
  end

  def show
    render json: job_sheet_json(@job_sheet)
  end

  def create
    @job_sheet = JobSheet.new(job_sheet_params)
    @job_sheet.site_id = @user.current_site_id
    @job_sheet.created_by = @user.id

    if @job_sheet.save
      render json: job_sheet_json(@job_sheet), status: :created
    else
      render json: { errors: @job_sheet.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @job_sheet.update(job_sheet_params)
      render json: job_sheet_json(@job_sheet)
    else
      render json: { errors: @job_sheet.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @job_sheet.destroy
    head :no_content
  end

  def check_in
    @job_sheet.update!(check_in_at: Time.current, status: "in_progress")
    render json: job_sheet_json(@job_sheet)
  end

  def check_out
    @job_sheet.update!(check_out_at: Time.current, status: "completed")
    render json: job_sheet_json(@job_sheet)
  end

  private

  def set_job_sheet
    @job_sheet = JobSheet.find(params[:id])
  end

  def job_sheet_params
    params.require(:job_sheet).permit(:ticket_id, :technician, :scheduled_at, :work_notes, :materials, :status, :signature)
  end

  def job_sheet_json(js)
    {
      id: js.id,
      ticketId: js.ticket_id,
      ticketNumber: js.ticket&.ticket_number,
      technician: js.technician,
      scheduledAt: js.scheduled_at,
      checkInAt: js.check_in_at,
      checkOutAt: js.check_out_at,
      workNotes: js.work_notes,
      materials: js.materials,
      status: js.status,
      signature: js.signature,
      createdAt: js.created_at,
    }
  end
end
