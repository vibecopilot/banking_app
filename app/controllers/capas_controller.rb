class CapasController < ApplicationController
  include UserExt
  protect_from_forgery with: :null_session
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_capa, only: %i[ show update destroy ]

  def index
    @capas = Capa.for_site(@user.current_site_id)
                 .includes(:complaint, :owner)
                 .order(created_at: :desc)
    render json: @capas.map { |c| capa_json(c) }
  end

  def show
    render json: capa_json(@capa)
  end

  def create
    @capa = Capa.new(capa_params)
    @capa.site_id = @user.current_site_id
    @capa.created_by = @user.id

    if @capa.save
      render json: capa_json(@capa), status: :created
    else
      render json: { errors: @capa.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @capa.update(capa_params)
      render json: capa_json(@capa)
    else
      render json: { errors: @capa.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @capa.destroy
    head :no_content
  end

  private

  def set_capa
    @capa = Capa.find(params[:id])
  end

  def capa_params
    params.require(:capa).permit(:complaint_id, :title, :root_cause, :corrective_action, :preventive_action, :effectiveness, :owner_id, :due_date, :status)
  end

  def capa_json(c)
    {
      id: c.id,
      complaintId: c.complaint_id,
      ticketNumber: c.complaint&.ticket_number,
      title: c.title,
      rootCause: c.root_cause,
      correctiveAction: c.corrective_action,
      preventiveAction: c.preventive_action,
      effectiveness: c.effectiveness,
      ownerId: c.owner_id,
      ownerName: c.owner&.full_name,
      dueDate: c.due_date,
      status: c.status,
      createdAt: c.created_at,
    }
  end
end
