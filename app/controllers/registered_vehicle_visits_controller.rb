class RegisteredVehicleVisitsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_vehicle_visit, only: %i[ show edit update destroy]


def index
  @q = RegisteredVehicleVisit
         .where(site_id: @user.current_site_id)
         .ransack(params[:q])

  @registered_vehicle_visits = @q
    .result
    .includes(:registered_vehicle, :user)
    .order(created_at: :desc)
    .page(params[:page])
    .per(params[:per_page] || 50)
end

    def show
  end

  def create
    visit = RegisteredVehicleVisit.new(visit_params)
    visit.check_in ||= Time.current

    if visit.save
      render json: {
        status: "success",
        data: visit
      }, status: :created
    else
      render json: {
        status: "error",
        errors: visit.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # PATCH /api/v1/registered_vehicle_visits/:id
  def update
    if @visit.update(check_out: Time.current)
      render json: {
        status: "success",
        data: @visit
      }
    else
      render json: {
        status: "error",
        errors: @visit.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private
  def set_vehicle_visit
    @visit = RegisteredVehicleVisit.find(params[:id])
  end

  def visit_params
    params.require(:registered_vehicle_visit)
          .permit(:registered_vehicle_id, :site_id, :created_by_id,:no_of_people)
  end
end

