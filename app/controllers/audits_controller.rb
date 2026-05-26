class AuditsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_audit, only: %i[ show edit update destroy ]

  # GET /audits or /audits.json
  def index
    @q = Audit.ransack(params[:q])
    base_scope = @q.result.where(site_id: @user.current_site_id).order(created_at: :desc)
    @audits = base_scope.page(params[:page]).per(params[:per_page] || 100)
  end

  # GET /audits/1 or /audits/1.json
  def show
  end

  # GET /audits/new
  def new
    @audit = Audit.new
  end

  # GET /audits/1/edit
  def edit
  end

  # POST /audits or /audits.json
  def create
    @audit = Audit.new(audit_params)

    respond_to do |format|
      if @audit.save
        if params.dig(:audit, :audit_tasks).present?
          params[:audit][:audit_tasks].each do |task_wrapper|
            raw_task =
            if task_wrapper.is_a?(ActionController::Parameters)
              task_hash = task_wrapper.to_unsafe_h
              # If values look like attributes, use directly
              if task_hash.key?("group") || task_hash.key?(:group)
                task_hash
              else
                task_hash.values.first
              end
            elsif task_wrapper.is_a?(Hash)
              if task_wrapper.key?("group") || task_wrapper.key?(:group)
                task_wrapper
              else
                task_wrapper.values.first
              end
            end
            next if raw_task.blank? || !raw_task.is_a?(Hash)
            permitted_task = ActionController::Parameters
            .new(raw_task)
            .permit(
              :group,
              :sub_group,
              :task,
              :input_type,
              :mandatory,
              :reading,
              :help_text,
              :weightage,
              :rating
            )
            @audit.audit_tasks.create!(permitted_task)
          end
        end
        format.html { redirect_to @audit, notice: "Audit was successfully created." }
        format.json { render :show, status: :created, location: @audit }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @audit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /audits/1 or /audits/1.json
  def update
    respond_to do |format|
      if @audit.update(audit_params)
        format.html { redirect_to @audit, notice: "Audit was successfully updated." }
        format.json { render :show, status: :ok, location: @audit }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @audit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /audits/1 or /audits/1.json
  def destroy
    @audit.destroy
    respond_to do |format|
      format.html { redirect_to audits_url, notice: "Audit was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_audit
    @audit = Audit.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def audit_params
    params.require(:audit).permit(:audit_for, :site_id, :activity_name, :description, :allow_observations, :checklist_type, :asset_name, :service_name, :vendor_name, :training_name, :assign_to, :scan_type, :plan_duration, :priority, :email_trigger_rule, :supervisors, :category, :look_overdue_task, :frequency, :start_from, :end_at, :select_supplier, :created_by_id)
  end
end
