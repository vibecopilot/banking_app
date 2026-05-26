class ComplianceTagsController < ApplicationController
  include UserExt
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_compliance_tag, only: %i[ show edit update destroy ]

  # GET /compliance_tags or /compliance_tags.json
  def index
    current_user = current_user || @user
    @compliance_tags = ComplianceTag.where(company_id: current_user.company_id).ransack(params[:q]).result
  end

  def tree_structure
    current_user = current_user || @user
    tags = ComplianceTag.where(parent_id: nil,resource_id: current_user.company_id) # Start with root nodes
    tags = tags.where(tag_type: params[:tag_type]) if params[:tag_type].present?
    render json: tags.map { |tag| tag_to_tree(tag) }
  end

  # GET /compliance_tags/1 or /compliance_tags/1.json
  def show
    tag = ComplianceTag.find(params[:id])
    render json: tag_with_hierarchy(tag)
  end
  # GET /compliance_tags/new
  def new
    @compliance_tag = ComplianceTag.new
  end

  # GET /compliance_tags/1/edit
  def edit
  end

  # POST /compliance_tags or /compliance_tags.json
  def create
    @compliance_tag = ComplianceTag.new(compliance_tag_params)

    respond_to do |format|
      if @compliance_tag.save
        format.html { redirect_to @compliance_tag, notice: "Compliance tag was successfully created." }
        format.json { render :show, status: :created, location: @compliance_tag }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @compliance_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /compliance_tags/1 or /compliance_tags/1.json
  def update
    respond_to do |format|
      if @compliance_tag.update(compliance_tag_params)
        format.html { redirect_to @compliance_tag, notice: "Compliance tag was successfully updated." }
        format.json { render :show, status: :ok, location: @compliance_tag }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @compliance_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /compliance_tags/1 or /compliance_tags/1.json
  def destroy
    @compliance_tag.destroy
    respond_to do |format|
      format.html { redirect_to compliance_tags_url, notice: "Compliance tag was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def tag_to_tree(tag, root_id = nil, parent_id = nil, grand_parent_id = nil)
      {
        id: tag.id,
        name: tag.name,
        tag_type: tag.tag_type,
        resource_id: tag.resource_id,
        resource_type: tag.resource_type,
        root_id: root_id || tag.id,               # Root ID for the node
        parent_id: parent_id,                     # Immediate Parent ID
        grand_parent_id: grand_parent_id,         # Grand Parent ID
        children: tag.children.map do |child|
          tag_to_tree(child, root_id || tag.id, tag.id, parent_id) # Pass current parent_id as grand_parent_id
        end
      }
    end

    def tag_with_hierarchy(tag)
      root = find_root(tag)
      parent = tag.parent

      {
        id: tag.id,
        name: tag.name,
        tag_type: tag.tag_type,
        resource_id: tag.resource_id,
        resource_type: tag.resource_type,
        root_id: root&.id,
        parent_id: parent&.id,
        children: tag.children.map { |child| tag_to_tree(child, root&.id, tag.id) }
      }
    end


    # Helper to find the root of a tag
    def find_root(tag)
      current = tag
      current = current.parent while current.parent
      current
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_compliance_tag
      @compliance_tag = ComplianceTag.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def compliance_tag_params
      params.require(:compliance_tag).permit(:name, :risk, :nature, :parent_id, :resource_id, :resource_type, :company_id, :tag_type, :critical)
    end
end
