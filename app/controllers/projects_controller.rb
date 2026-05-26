class ProjectsController < ApplicationController
  include UserExt
  before_action :authenticate_user!, if: :check_html_format
  before_action :set_user
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  before_action :set_current_user
  layout 'basic'

  # GET /projects
  # GET /projects.json
  def index
    @projects = current_user.projects
    @project = Project.new
    if params[:format] == "json"
      render json: {"projects": @projects.as_json(include: { tasks: { methods: [:id, :name, :tat, :priority, :status] }})}
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
  end

  def user_project
    user = current_user
    render json: {
      id: user.id,
      city: "--",
      pincode: "--",
      state: "--",
      address_line_one: "--",
      address_line_two: "--",
      intercom_number: user.intercom_number,
      user_sites: user.user_sites.map do |site|
        {
          id: site.id,
          unit_id: site.unit_id,
          unit_name: site.unit&.name,
          floor_id: site.unit.floor&.id,
          floor_name: site.unit.floor&.name,
          tower_id: site.unit.floor&.building&.id,
          tower_name: site.unit.floor.building&.name,
          ownership: site.ownership,
          lives_here: site.lives_here 
        }
      end
    }
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.json
  def create
    # binding.pry
    @project = current_user.projects.build(project_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to "/", notice: 'Project was successfully created.' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to "/", notice: 'Project was successfully updated.' }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to "/", notice: 'Project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = Project.find(params[:id])
    authorize! :show, @project
  end

  def set_current_user
    @current_user = User.find_by(api_key: params[:token])
    reder json: {erro: "Unauth"}, status: 401 unless @current_user
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def project_params
    params.require(:project).permit(:user_id, :name, :active, :city,
                                    :pincode,
                                    :state,
                                    :flat_no,
                                    :intercom,
                                    :ownership,
                                    :lives_here,
                                    :is_primary,
                                    :address_line_one,
                                    :address_line_two, :tasks_attributes => [:id, :name, :tat, :status])
  end
end
