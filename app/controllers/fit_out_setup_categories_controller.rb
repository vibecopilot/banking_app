class FitOutSetupCategoriesController < ApplicationController
  before_action :set_fit_out_setup_category, only: %i[show edit update destroy]

  def index
    @fit_out_setup_categories = FitOutSetupCategory.order(created_at: :desc)
    render json: @fit_out_setup_categories.as_json(
      methods: [],
      include: {
        attachfile: { only: [], methods: [:document_url] }
      }
    )
  end

  def show
    @fit_out_setup_category = FitOutSetupCategory.find(params[:id])
    render json: @fit_out_setup_category
  end

  def new
    @fit_out_setup_category = FitOutSetupCategory.new
  end

  def create
    @fit_out_setup_category = FitOutSetupCategory.new(fit_out_setup_category_params)
    @fit_out_setup_category.response_tat = params[:response_tat].present? ? params[:response_tat].to_json : "{}"
    respond_to do |format|
      if @fit_out_setup_category.save
        # Handle Attachments
        if params[:attachfiles].present?
          params[:attachfiles].each do |doc|
            Attachfile.create(image: doc, relation: "FitOutSetupCategoryIcon", relation_id: @fit_out_setup_category.id, active: 1)
          end
        end

        # Handle Complaint Worker Assignments
        if params[:complaint_worker].present? && params[:complaint_worker][:assign_to].present?
          if ComplaintWorker.pms.where(category_id: @fit_out_setup_category.id).applicable_cw_for(@user.current_site_id, @user.selected_site_id).present?
            ComplaintWorker.pms.where(category_id: @fit_out_setup_category.id).applicable_cw_for(@user.current_site_id, @user.selected_site_id).update(site_id: @user.selected_site_id, assign_to: params[:complaint_worker][:assign_to])
          else
            ComplaintWorker.create(site_id: @user.selected_site_id, society_id: @fit_out_setup_category.society_id, issue_type_id: nil, category_id: @fit_out_setup_category.id, assign_to: params[:complaint_worker][:assign_to], esc_type: nil, of_phase: "pms", of_atype: "Society")
          end
        end

        # Handle Category Emails
        if params[:category_email].present? && params[:category_email][:email].present?
          emails = params[:category_email][:email].split(/,\s*/)
          emails.each do |email|
            CategoryEmail.create(site_id: @user.try(:selected_pms_site).try(:pms_site).try(:id), cat_id: @fit_out_setup_category.id, email: email)
          end
        end

        format.html { redirect_to params[:fit_out_setup_category][:custom_redirect] || @fit_out_setup_category, notice: "Category was successfully created." }
        format.json { render json: @fit_out_setup_category, status: :created }
      else
        format.html { render :new }
        format.json { render json: @fit_out_setup_category.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    # binding.pry
    if @fit_out_setup_category.update(fit_out_setup_category_params)
      respond_to do |format|
        format.html { redirect_to @fit_out_setup_category, notice: "Category was successfully updated." }
        format.json { render json: @fit_out_setup_category, status: :ok }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: @fit_out_setup_category.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @fit_out_setup_category.destroy
    respond_to do |format|
      format.html { redirect_to fit_out_setup_categories_url, notice: "Category was successfully deleted." }
      format.json { head :no_content }
    end
  end


  private

  def set_fit_out_setup_category
    @fit_out_setup_category = FitOutSetupCategory.find(params[:id])
  end

  def fit_out_setup_category_params
    params.require(:fit_out_setup_category).permit(:name, :position, :assigned_id, :society_id, :tat, :active, :issue_type_id, :of_phase, :of_atype, :icon_file_name, :icon_content_type, :icon_file_size, :icon_updated_at, :response_tat, :project_tat)
  end
end
