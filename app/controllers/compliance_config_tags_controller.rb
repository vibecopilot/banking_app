class ComplianceConfigTagsController < ApplicationController
  include UserExt
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_compliance_config_tag, only: %i[ show edit update destroy ]

  # GET /compliance_config_tags or /compliance_config_tags.json
  def index
    @compliance_config_tags = ComplianceConfigTag.all
  end

  # GET /compliance_config_tags/1 or /compliance_config_tags/1.json
  def show
  end

  # GET /compliance_config_tags/new
  def new
    @compliance_config_tag = ComplianceConfigTag.new
  end

  # GET /compliance_config_tags/1/edit
  def edit
  end

  # POST /compliance_config_tags or /compliance_config_tags.json
  def create
    tasks_data = params[:compliance_config_tags]

    # Check if the payload contains multiple tasks or just a single task
    if tasks_data.is_a?(Array)
      # Handle multiple tasks
      tasks_data.each do |task_data|
        # Permit the attributes for each task
        task_params = task_data.permit(:compliance_tag_id, :compliance_config_id)

        @compliance_config_tag = ComplianceConfigTag.new(task_params)

        if @compliance_config_tag.save
          # Successfully created a task
          flash[:notice] = "Compliance Config Tags were successfully created."
        else
          # If any task fails to save, render errors for the first failed task
          flash[:error] = "One or more Tags are invalid."
          render :new and return
        end
      end

      # If all tasks are created successfully, redirect to index
      respond_to do |format|
        format.html { redirect_to compliance_config_tags_path, notice: flash[:notice] }
        format.json { render :index, status: :created, location: compliance_config_tags_path }
      end
    else
      # Handle single task creation if the payload is not an array
      @compliance_config_tag = ComplianceConfigTag.new(compliance_config_tag_params)

      respond_to do |format|
        if @compliance_config_tag.save
          format.html { redirect_to @compliance_config_tag, notice: "Compliance config tag was successfully created." }
          format.json { render :show, status: :created, location: @compliance_config_tag }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @compliance_config_tag.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /compliance_config_tags/1 or /compliance_config_tags/1.json
  def update
    respond_to do |format|
      if @compliance_config_tag.update(compliance_config_tag_params)
        format.html { redirect_to @compliance_config_tag, notice: "Compliance config tag was successfully updated." }
        format.json { render :show, status: :ok, location: @compliance_config_tag }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @compliance_config_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /compliance_config_tags/1 or /compliance_config_tags/1.json
  def destroy
    @compliance_config_tag.destroy
    respond_to do |format|
      format.html { redirect_to compliance_config_tags_url, notice: "Compliance config tag was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_compliance_config_tag
      @compliance_config_tag = ComplianceConfigTag.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def compliance_config_tag_params
      params.require(:compliance_config_tag).permit(:compliance_tag_id, :compliance_config_id)
    end
end
