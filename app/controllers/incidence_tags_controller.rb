class IncidenceTagsController < ApplicationController
  include UserExt
  before_action :authenticate_user!, if: :check_user
  # before_action :api_user
  before_action :set_user
  before_action :set_incidence_tag, only: %i[ show edit update destroy ]

  # GET /incidence_tags or /incidence_tags.json
  def index
    @incidence_tags = IncidenceTag.where(resource_id: @user.company_id).ransack(params[:q]).result
  end

  def tree_structure
    tags = IncidenceTag.where(parent_id: nil) # Start with root nodes
    tags = tags.where(tag_type: params[:tag_type]) if params[:tag_type].present?
    render json: tags.map { |tag| tag_to_tree(tag) }
  end

  # GET /incidence_tags/1 or /incidence_tags/1.json
  def show
    tag = IncidenceTag.find(params[:id])
    render json: tag_with_hierarchy(tag)
  end

  # GET /incidence_tags/new
  def new
    @incidence_tag = IncidenceTag.new
  end

  # GET /incidence_tags/1/edit
  def edit
    # if (@incidence_tag.tag_type == "IncidenceSubSubCategory")
    #   @categorys = IncidenceTag.where(society_id: @curusoc.id_society, tag_type: "IncidenceCategory")
    #   @category_options = @categorys.map{|u| [u.name, u.id]}
    #   @selected_category_option = @incidence_tag.parent&.parent&.id

    #   @sub_categorys = IncidenceTag.where(society_id: @curusoc.id_society, tag_type: "IncidenceSubCategory", id: @incidence_tag.parent_id)
    #   @sub_category_options = @sub_categorys.map{|u| [u.name, u.id]}
    #   @selected_sub_category_option = @incidence_tag.parent_id

    # elsif (@incidence_tag.tag_type == "IncidenceSubSubSubCategory")
    #   @categorys = IncidenceTag.where(society_id: @curusoc.id_society, tag_type: "IncidenceCategory")
    #   @category_options = @categorys.map{|u| [u.name, u.id]}
    #   @selected_category_option = @incidence_tag.parent&.parent&.parent&.id

    #   @sub_categorys = IncidenceTag.where(society_id: @curusoc.id_society, tag_type: "IncidenceSubCategory", parent_id: @incidence_tag.parent&.parent&.parent&.id)
    #   @sub_category_options = @sub_categorys.map{|u| [u.name, u.id]}
    #   @selected_sub_category_option = @incidence_tag.parent&.parent&.id

    #   @sub_sub_categorys = IncidenceTag.where(society_id: @curusoc.id_society, tag_type: "IncidenceSubSubCategory", parent_id: @incidence_tag.parent&.parent&.id)
    #   @sub_sub_category_options = @sub_sub_categorys.map{|u| [u.name, u.id]}
    #   @selected_sub_sub_category_option = @incidence_tag.parent&.id

    #   #incidence secondry category start

    # elsif (@incidence_tag.tag_type == "IncidenceSecondarySubSubCategory")
    #   @sec_categorys = IncidenceTag.where(society_id: @curusoc.id_society, tag_type: "IncidenceSecondaryCategory")
    #   @sec_category_options = @sec_categorys.map{|u| [u.name, u.id]}
    #   @selected_sec_category_option = @incidence_tag.parent&.parent&.id

    #   @sec_sub_categorys = IncidenceTag.where(society_id: @curusoc.id_society, tag_type: "IncidenceSecondarySubCategory", id: @incidence_tag.parent_id)
    #   @sec_sub_category_options = @sec_sub_categorys.map{|u| [u.name, u.id]}
    #   @selected_sec_sub_category_option = @incidence_tag.parent_id

    # elsif (@incidence_tag.tag_type == "IncidenceSecondarySubSubSubCategory")
    #   @sec_categorys = IncidenceTag.where(society_id: @curusoc.id_society, tag_type: "IncidenceSecondaryCategory")
    #   @sec_category_options = @sec_categorys.map{|u| [u.name, u.id]}
    #   @selected_sec_category_option = @incidence_tag.parent&.parent&.parent&.id

    #   @sec_sub_categorys = IncidenceTag.where(society_id: @curusoc.id_society, tag_type: "IncidenceSecondarySubCategory", parent_id: @incidence_tag.parent&.parent&.parent&.id)
    #   @sec_sub_category_options = @sec_sub_categorys.map{|u| [u.name, u.id]}
    #   @selected_sec_sub_category_option = @incidence_tag.parent&.parent&.id

    #   @sec_sub_sub_categorys = IncidenceTag.where(society_id: @curusoc.id_society, tag_type: "IncidenceSecondarySubSubCategory", parent_id: @incidence_tag.parent&.parent&.id)
    #   @sec_sub_sub_category_options = @sec_sub_sub_categorys.map{|u| [u.name, u.id]}
    #   @selected_sec_sub_sub_category_option = @incidence_tag.parent&.id

    # end
  end

  # POST /incidence_tags or /incidence_tags.json
  def create
    @incidence_tag = IncidenceTag.new(incidence_tag_params)

    respond_to do |format|
      if @incidence_tag.save
        format.html { redirect_to @incidence_tag, notice: "Incidence tag was successfully created." }
        format.json { render :show, status: :created, location: @incidence_tag }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @incidence_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /incidence_tags/1 or /incidence_tags/1.json
  def update
    respond_to do |format|
      if @incidence_tag.update(incidence_tag_params)
        format.html { redirect_to @incidence_tag, notice: "Incidence tag was successfully updated." }
        format.json { render :show, status: :ok, location: @incidence_tag }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @incidence_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /incidence_tags/1 or /incidence_tags/1.json
  def destroy
    @incidence_tag.destroy
    respond_to do |format|
      format.html { redirect_to incidence_tags_url, notice: "Incidence tag was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def tag_to_tree(tag, root_id = nil, parent_id = nil, grand_parent_id = nil)
    {
      id: tag.id,
      name: tag.name,
      active: tag.active,
      tag_type: tag.tag_type,
      resource_id: tag.resource_id,
      resource_type: tag.resource_type,
      comment: tag.comment,
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
      active: tag.active,
      tag_type: tag.tag_type,
      resource_id: tag.resource_id,
      resource_type: tag.resource_type,
      comment: tag.comment,
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
  def set_incidence_tag
    @incidence_tag = IncidenceTag.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def incidence_tag_params
    params.require(:incidence_tag).permit(:name, :active, :parent_id, :tag_type, :resource_id, :resource_type, :comment)
  end
end
