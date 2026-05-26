class CommunicationGroupsController < ApplicationController
   include UserExt
  before_action :authenticate_user!, if: :check_user
  #load_and_authorize_resource if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_communication_group, only: [:show, :update, :destroy]

  # GET /communication_groups
  def index
    @q = CommunicationGroup.ransack(params[:q]) # Initialize the Ransack search object
    @communication_groups = @q.result(distinct: true) # Get the filtered results
    #@communication_groups = CommunicationGroup.all
    render json: @communication_groups
  end

  def new
    @employees = User.employees
    render json: @employees
  end

  # GET /communication_groups/:id
  def show
    render json: @communication_group
  end

  # POST /communication_groups
  def create
    @communication_group = CommunicationGroup.new(communication_group_params)
    if @communication_group.save
      render json: @communication_group, status: :created
    else
      render json: { errors: @communication_group.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /communication_groups/:id
  def update
    if @communication_group.update(communication_group_params)
      render json: @communication_group
    else
      render json: { errors: @communication_group.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /communication_groups/:id
  def destroy
    @communication_group.destroy
    head :no_content
  end

  private

  def set_communication_group
    @communication_group = CommunicationGroup.find(params[:id])
  end

  def communication_group_params
    params.require(:communication_group).permit(:name, :description, :picture, user_ids: [])
  end
end
