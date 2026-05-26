class VisitorSubCategoriesController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_visitor_sub_category, only: %i[ show edit update destroy ]

  # GET /visitor_sub_categories or /visitor_sub_categories.json
def index
  @q = VisitorSubCategory.ransack(params[:q])

  base_scope = @q.result
                 .joins(:visitor_category)
                 .where(
                   visitor_categories: {
                     site_id: params[:site_id] || @user.current_site_id
                   }
                 )
                 .includes(:iconv2)
                 .order(created_at: :desc)

  @visitor_sub_categories = base_scope.page(params[:page])
                                      .per(params[:per_page] || 50)
end

  # GET /visitor_sub_categories/1 or /visitor_sub_categories/1.json
  def show
  end

  # GET /visitor_sub_categories/new
  def new
    @visitor_sub_category = VisitorSubCategory.new
  end

  # GET /visitor_sub_categories/1/edit
  def edit
  end

  # POST /visitor_sub_categories or /visitor_sub_categories.json
  def create
    @visitor_sub_category = VisitorSubCategory.new(visitor_sub_category_params)

    respond_to do |format|
      if @visitor_sub_category.save

        if params[:visitor_sub_category][:iconv2].present?
          Attachfile.create(
            image: params[:visitor_sub_category][:iconv2],
            relation: "VisitorSubCategory",
            relation_id: @visitor_sub_category.id,
            active: 1
            )
        end

        format.html { redirect_to @visitor_sub_category, notice: "Visitor sub category was successfully created." }
        format.json { render :show, status: :created, location: @visitor_sub_category }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @visitor_sub_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /visitor_sub_categories/1 or /visitor_sub_categories/1.json
  def update
    respond_to do |format|
      if @visitor_sub_category.update(visitor_sub_category_params)
        format.html { redirect_to @visitor_sub_category, notice: "Visitor sub category was successfully updated." }
        format.json { render :show, status: :ok, location: @visitor_sub_category }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @visitor_sub_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /visitor_sub_categories/1 or /visitor_sub_categories/1.json
  def destroy
    @visitor_sub_category.destroy
    respond_to do |format|
      format.html { redirect_to visitor_sub_categories_url, notice: "Visitor sub category was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_visitor_sub_category
      @visitor_sub_category = VisitorSubCategory.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def visitor_sub_category_params
      params.require(:visitor_sub_category).permit(:visitor_category_id, :name, :active, iconv2_attributes: [
      :id,
      :image,
      :_destroy
    ])
    end
end
