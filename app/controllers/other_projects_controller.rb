class OtherProjectsController < ApplicationController
  include UserExt
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_other_project, only: %i[ show edit update destroy ]

  # GET /other_projects or /other_projects.json
  def index
    @other_projects = OtherProject.where(company_id: @user.company_id)
  end

  # GET /other_projects/1 or /other_projects/1.json
  def show
  end

  # GET /other_projects/new
  def new
    @other_project = OtherProject.new
    @other_project.other_p_amenities.build
  end

  # GET /other_projects/1/edit
  def edit
  end
  
  # POST /other_projects or /other_projects.json
  def create
    @other_project = OtherProject.new(other_project_params)
    @other_project.company_id = @user.company_id
    respond_to do |format|
      if @other_project.save
        params[:attachments].each do |doc|
            Attachfile.create(image: doc, relation: "OtherProject", relation_id: @other_project.id, active: 1)
        end
         if params[:pdf].present? 
          params[:pdf].each do |doc|
          Attachfile.create(image: doc, relation: "OtherProjectPDF", relation_id: @other_project.id, active: 1)
          end
        end
        if params[:amenity_icons].present?
          @other_project.other_p_amenities.each_with_index do |amenity, index|
            icon_file = params[:amenity_icons][index.to_s]
            next if icon_file.blank?
            Attachfile.create(image: icon_file, relation: "OtherPAmenityIcon", relation_id: amenity.id, active: 1)
          end
        end
        format.html { redirect_to @other_project, notice: "Other project was successfully created." }
        format.json { render :show, status: :created, location: @other_project }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @other_project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /other_projects/1 or /other_projects/1.json
  def update
  respond_to do |format|
    if @other_project.update(other_project_params)
      
      # Delete old attachments
      if params[:attachments].present?
        Attachfile.where(relation: "OtherProject", relation_id: @other_project.id).destroy_all
        
        # Add new attachments
        params[:attachments].each do |doc|
          Attachfile.create!(
            relation: "OtherProject",
            relation_id: @other_project.id,
            active: 1,
            image: doc
          )
        end
      end

       # Delete old cover images
      if params[:pdf].present?
        Attachfile.where(relation: "OtherProjectPDF", relation_id: @other_project.id).destroy_all

        # Add new cover images
        params[:pdf].each do |doc|
          Attachfile.create!(
            relation: "OtherProjectPDF",
            relation_id: @other_project.id,
            active: 1,
            image: doc
          )
        end
      end

      if params[:amenity_icons].present?
        @other_project.other_p_amenities.each_with_index do |amenity, index|
          icon_file = params[:amenity_icons][index.to_s]
          next if icon_file.blank?
          amenity.amenity_icon&.destroy
          Attachfile.create!(image: icon_file, relation: "OtherPAmenityIcon", relation_id: amenity.id, active: 1)
        end
      end
      format.html { redirect_to @other_project, notice: "Other project was successfully updated." }
      format.json { render :show, status: :ok, location: @other_project }
    else
      format.html { render :edit, status: :unprocessable_entity }
      format.json { render json: @other_project.errors, status: :unprocessable_entity }
    end
  end
end


  # DELETE /other_projects/1 or /other_projects/1.json
  def destroy
    @other_project.destroy
    respond_to do |format|
      format.html { redirect_to other_projects_url, notice: "Other project was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_other_project
      @other_project = OtherProject.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def other_project_params
      params.require(:other_project).permit(:title, :description, :address, :company_id, :contact_us, other_p_amenities_attributes: [:id, :name, :_destroy])
    end
end
