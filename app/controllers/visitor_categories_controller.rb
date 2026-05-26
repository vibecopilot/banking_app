class VisitorCategoriesController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_visitor_category, only: %i[ show edit update destroy ]

  # GET /visitor_categories or /visitor_categories.json
  def index
    @q = VisitorCategory.ransack(params[:q])
    base_scope = @q.result.where(site_id: @user.current_site_id).order(created_at: :desc)
    @visitor_categories = base_scope.page(params[:page]).per(params[:per_page] || 20)
  end

  # GET /visitor_categories/1 or /visitor_categories/1.json
  def show
  end

  # GET /visitor_categories/new
  def new
    @visitor_category = VisitorCategory.new
  end

  # GET /visitor_categories/1/edit
  def edit
  end

  # POST /visitor_categories or /visitor_categories.json
  def create
    @visitor_category = VisitorCategory.new(visitor_category_params)

    respond_to do |format|
      if @visitor_category.save
        # if params[:visitor_category][:icon].present?
        #   Attachfile.create(
        #     image: params[:visitor_category][:icon],
        #     relation: "VisitorCategory",
        #     relation_id: @visitor_category.id,
        #     active: 1
        #     )
        # end
        format.html { redirect_to @visitor_category, notice: "Visitor category was successfully created." }
        format.json { render :show, status: :created, location: @visitor_category }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @visitor_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /visitor_categories/1 or /visitor_categories/1.json
  def update
    respond_to do |format|
      if @visitor_category.update(visitor_category_params)
        format.html { redirect_to @visitor_category, notice: "Visitor category was successfully updated." }
        format.json { render :show, status: :ok, location: @visitor_category }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @visitor_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /visitor_categories/1 or /visitor_categories/1.json
  def destroy
    @visitor_category.destroy
    respond_to do |format|
      format.html { redirect_to visitor_categories_url, notice: "Visitor category was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_visitor_category
      @visitor_category = VisitorCategory.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def visitor_category_params
      params.require(:visitor_category).permit(:name, :code, :active, :site_id,
       icon_attributes: [
      :id,
      :image,
      :_destroy
    ])
    end
end
