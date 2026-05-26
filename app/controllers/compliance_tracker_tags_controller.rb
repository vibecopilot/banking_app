class ComplianceTrackerTagsController < ApplicationController
  include UserExt
  before_action :set_compliance_tracker_tag, only: %i[ show edit update destroy ]

  # GET /compliance_tracker_tags or /compliance_tracker_tags.json
  def index
    @compliance_tracker_tags = ComplianceTrackerTag.all
  end

  # GET /compliance_tracker_tags/1 or /compliance_tracker_tags/1.json
  def show
  end

  # GET /compliance_tracker_tags/new
  def new
    @compliance_tracker_tag = ComplianceTrackerTag.new
  end

  # GET /compliance_tracker_tags/1/edit
  def edit
  end

  # POST /compliance_tracker_tags or /compliance_tracker_tags.json
  def create
    compliance_tracker_tags_data = params[:compliance_tracker_tags] || { "0" => params[:compliance_tracker_tag] }

    created_or_updated_tags = []
    errors = []
    compliance_tracker_id = nil

    compliance_tracker_tags_data.each do |_key, tag_data|
      tag_params = tag_data.permit(:compliance_tracker_id, :submitted_by_id, :compliance_tag_id, :observation, :recommendtion, :comment, :compliance_tag_task_id,:reviewed_by_id,:objective,:reviewed_on,:status)

      # Find or initialize ComplianceTrackerTag
      compliance_tracker_tag = ComplianceTrackerTag.find_or_initialize_by(
        compliance_tracker_id: tag_params[:compliance_tracker_id],
        compliance_tag_id: tag_params[:compliance_tag_id],
        compliance_tag_task_id: tag_params[:compliance_tag_task_id]
      )

      # Update attributes
      compliance_tracker_tag.assign_attributes(tag_params)
      compliance_tracker_tag.submitted_on ||= Time.current  # Only set if it's nil (preserves previous values)

      if compliance_tracker_tag.save
        created_or_updated_tags << compliance_tracker_tag
        compliance_tracker_id = tag_params[:compliance_tracker_id]
        # Handle attachments
        if tag_data[:attachments].present?
          tag_data[:attachments].each do |_key, doc|
            Attachfile.create(image: doc, relation: "ComplianceTrackerTag", relation_id: compliance_tracker_tag.id, active: 1)
          end
        end
      else
        errors << { tag_data: tag_data, errors: compliance_tracker_tag.errors.full_messages }
      end
    end

    respond_to do |format|
      if errors.empty?
        format.html { redirect_to compliance_tracker_tags_path, notice: "Compliance tracker tags were successfully created or updated." }
        format.json { render json: { message: "Compliance tracker tags were successfully created or updated.", tags: created_or_updated_tags }, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity, alert: "Some compliance tracker tags failed to process." }
        format.json { render json: { errors: errors }, status: :unprocessable_entity }
      end
    end
    ComplianceTracker.find_by(id: compliance_tracker_id).update(status: "submitted", submitted_on: Time.zone.now, submitted_by_id: @user&.id) if compliance_tracker_id.present?
  end




  # PATCH/PUT /compliance_tracker_tags/1 or /compliance_tracker_tags/1.json
  def update
    respond_to do |format|
      if @compliance_tracker_tag.update(compliance_tracker_tag_params)
        format.html { redirect_to @compliance_tracker_tag, notice: "Compliance tracker tag was successfully updated." }
        format.json { render :show, status: :ok, location: @compliance_tracker_tag }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @compliance_tracker_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /compliance_tracker_tags/1 or /compliance_tracker_tags/1.json
  def destroy
    @compliance_tracker_tag.destroy
    respond_to do |format|
      format.html { redirect_to compliance_tracker_tags_url, notice: "Compliance tracker tag was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_compliance_tracker_tag
      @compliance_tracker_tag = ComplianceTrackerTag.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def compliance_tracker_tag_params
      params.require(:compliance_tracker_tag).permit(:compliance_tracker_id, :submitted_on, :submitted_by_id, :compliance_tag_id, :observation, :recommendtion, :comment, :compliance_tag_task_id,:reviewed_by_id,:objective,:reviewed_on,:status)
    end
end
