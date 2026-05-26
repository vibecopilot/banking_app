class SubmissionsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user, except: [:export_readings]
  before_action :api_user, except: [:export_readings]
  before_action :set_user, except: [:export_readings]
  before_action :set_submission, only: %i[ show edit update destroy ]

  # GET /submissions or /submissions.json
  def index
    if params[:format] == "json"
      # If specific filters are provided (like activity_id), use them directly
      if params[:q].present? && (params[:q][:activity_id_eq].present? || params[:q][:asset_id_eq].present?)
        @submissions = Submission.includes(:activity, :site_asset, :checklist, :user, :question, :soft_service)
        .ransack(params[:q])
        .result
        .order(question_id: :asc)
      else
        # Otherwise, filter by site
        @submissions = Submission.includes(:activity, :site_asset, :checklist, :user, :question, :soft_service)
        .ransack({ combinator: 'or', groupings: [
                     { site_asset_site_id_eq: @user.current_site_id },
                     { soft_service_site_id_eq: @user.current_site_id }
        ] })
        .result
        .ransack(params[:q])
        .result
        .order(question_id: :asc)
      end
      @consumption_map = {}
      grouped = @submissions.group_by { |s| [s.asset_id, s.asset_param_id] }
      grouped.each do |_key, subs|
        sorted = subs.sort_by(&:created_at)
        prev_value = nil
        sorted.each do |s|
          current_value = s.value.to_f if s.value.present? && s.value.to_s.match?(/\A-?\d+(\.\d+)?\z/)
          if current_value && prev_value
            @consumption_map[s.id] = (current_value - prev_value).round(4)
          else
            @consumption_map[s.id] = nil
          end
          prev_value = current_value if current_value
        end
      end
    else
      @submissions = Submission.ransack(site_asset_site_id_eq: @user.current_site_id).result.ransack(params[:q]).result.order(created_at: :desc).pluck(:asset_id, :checklist_id).uniq
    end
  end

  # GET /submissions/1 or /submissions/1.json
  def show
  end

  def showit
    render :show
  end

  # GET /submissions/new
  def new
    @submission = Submission.new
  end

  def take_reading
    @submission = Submission.new
  end

  # GET /submissions/1/edit
  def edit
  end

  # def export_readings
  #   asset = SiteAsset.find_by(id: params[:asset_id] || params[:q][:asset_id_eq])
  #   soft_service = SoftService.find_by(id: params[:soft_service_id])

  #   # Date range filters
  #   if params[:date_range].present?
  #     @date_range = params[:date_range].split(" - ")
  #     params[:q] ||= {}
  #     params[:q][:start_time_lteq] = Date.strptime(@date_range[1], "%m/%d/%Y").strftime("%d/%m/%Y")
  #     params[:q][:start_time_gteq] = Date.strptime(@date_range[0], "%m/%d/%Y").strftime("%d/%m/%Y")
  #   else
  #     params[:q] ||= {
  #       start_time_gteq: Date.today.beginning_of_month.strftime('%d/%m/%Y'),
  #       start_time_lteq: Date.today.end_of_month.strftime('%d/%m/%Y')
  #     }
  #   end

  #   if asset.present?
  #     params[:q][:asset_id_eq] = asset.id
  #   elsif soft_service.present?
  #     params[:q][:soft_service_id_eq] = soft_service.id
  #   end

  #   @occurrences = Activity.ransack(params[:q]).result
  #   @submissions = Submission.includes(:site_asset, :checklist, :question, :soft_service, :asset_param, :user)
  #   .where(activity_id: @occurrences.pluck(:id))

  #   # binding.pry

  #   respond_to do |format|
  #     format.xlsx { render xlsx: "export_excel", filename: "readings_export_#{Time.now.strftime('%Y%m%d%H%M%S')}.xlsx" }
  #   end
  # end

  def export_readings
    params[:q] ||= {}

    asset = SiteAsset.find_by(id: params[:asset_id] || params.dig(:q, :asset_id_eq))
    soft_service = SoftService.find_by(id: params[:soft_service_id])

    if params[:start_date].present?
      params[:q][:created_at_gteq] =
        Date.strptime(params[:start_date], "%m/%d/%Y").beginning_of_day
    end

    if params[:end_date].present?
      params[:q][:created_at_lteq] =
        Date.strptime(params[:end_date], "%m/%d/%Y").end_of_day
    end
    #params[:q][:created_at_gteq] ||= Date.today.beginning_of_month.beginning_of_day
    #params[:q][:created_at_lteq] ||= Date.today.end_of_month.end_of_day
    #end

    if asset.present?
      params[:q][:asset_id_eq] = asset.id
    elsif soft_service.present?
      params[:q][:soft_service_id_eq] = soft_service.id
    end
    if params[:q][:asset_param_id_null].blank?
      params[:q].delete(:asset_param_id_null)
    end

    @submissions = Submission
    .includes(:site_asset, :checklist, :question, :soft_service, :asset_param, :user)
    .ransack(params[:q]).result
    .order(:asset_id, :asset_param_id, :created_at)

    # binding.pry
    @consumption_map = {}
    grouped = @submissions.group_by { |s| [s.asset_id, s.asset_param_id] }
    grouped.each do |_key, subs|
      sorted = subs.sort_by(&:created_at)

      prev_value = nil

      sorted.each do |s|
        if s.value.present? && s.value.to_s.match?(/\A-?\d+(\.\d+)?\z/)
          current_value = s.value.to_f

          if prev_value.present?
            @consumption_map[s.id] = (current_value - prev_value).round(4)
          else
            @consumption_map[s.id] = nil
          end

          prev_value = current_value
        else
          @consumption_map[s.id] = nil
        end
      end
    end

    respond_to do |format|
      format.xlsx do
        render xlsx: "export_excel",
          filename: "readings_export_#{Time.now.strftime('%Y%m%d%H%M%S')}.xlsx"
      end
    end
  end


  # def multiple_readings

  # end

  # POST /submissions or /submissions.json
  # def create
  #   if params[:for_asset_params].present?
  #     act = Activity.create(asset_id: params[:submission][:asset_id], start_time: Time.zone.now, status: "complete", assigned_to: @user.id)
  #     params[:asset_params].each do |ap|
  #       @submission = Submission.create(asset_id: params[:submission][:asset_id], activity_id: act.id, asset_param_id: ap[:asset_param_id], value: ap[:value], user_id: @user.id)
  #       puts @submission.errors
  #     end
  #     if params[:format] != "json"
  #     redirect_to "/site_assets/#{params[:submission][:asset_id]}", notice: "Readings recorded successfully" and return
  #     end
  #   else
  #     @submission = Submission.new(submission_params)
  #     activity_partially_complete = false
  #     if params[:submission][:questions].present?
  #       params[:submission][:questions].each do |key, value|
  #         @submission = Submission.create(submission_params.merge(question_id: key, value: value[:value]))
  #         if value[:attachfiles].present?
  #           files = value[:attachfiles].is_a?(Array) ? value[:attachfiles] : [value[:attachfiles]]
  #           files.each do |file|
  #             if file.is_a?(ActionDispatch::Http::UploadedFile)
  #               Attachfile.create(
  #                 image: file,
  #                 relation: "Question-#{key}",
  #                 relation_id: @submission.id,
  #                 active: 1
  #               )
  #             elsif file.is_a?(String) && file.start_with?('data:image')
  #               file_path = if file.include?('image/png')
  #                 Attachfile.createpng(file)
  #               else
  #                 Attachfile.createimage(file)
  #               end
  #               Attachfile.create(
  #                 image: File.open(file_path),
  #                 relation: "Question-#{key}",
  #                 relation_id: @submission.id,
  #                 active: 1
  #               )
  #               File.delete(file_path) if File.exist?(file_path)
  #             end
  #           end
  #         end
  #       end
  #     end

  #     if params[:questions_arr].present?
  #       params[:questions_arr].each do |key, value|
  #         @submission = Submission.create(submission_params.merge(:question_id => value[:id], :value => value[:option])) #value should be there?
  #         puts @submission.errors
  #       end
  #     end

  #   end

  #   respond_to do |format|
  #     if @submission.save
  #       if params[:attachfiles].present?
  #         params[:attachfiles].each do |doc|
  #           Attachfile.create(image: doc, relation: "SubmissionDocuments", relation_id: @submission.id, active: 1)
  #         end
  #       end
  #       # update_associated_activities(@submission.activity, activity_partially_complete)
  #       @submission.activity.update(status: "complete") if @submission.activity.present?
  #       format.html { redirect_to @submission, notice: "Submission was successfully created." }
  #       format.json { render :show, status: :created, location: @submission }
  #     else
  #       format.html { render :new, status: :unprocessable_entity }
  #       format.json { render json: @submission.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  def create
    @user.with_lock do
      if params[:for_asset_params].present?
        act = Activity.create(
          asset_id: params[:submission][:asset_id],
          start_time: Time.zone.now,
          status: "complete",
          assigned_to: @user.id
        )
        params[:asset_params].each do |ap|
          # binding.pry
          @submission = Submission.create(
            asset_id: params[:submission][:asset_id],
            activity_id: act.id,
            asset_param_id: ap[:asset_param_id],
            value: ap[:value],
            user_id: @user.id,
            comment: ap[:comment]
          )
          puts @submission.errors
        end
        if params[:format] != "json"
          redirect_to "/site_assets/#{params[:submission][:asset_id]}",
            notice: "Readings recorded successfully" and return
        end
      else
        @submission = Submission.new(submission_params)
        activity_partially_complete = false

        if params[:submission][:questions].present?
          params[:submission][:questions].each do |key, value|
            # binding.pry
            @submission = Submission.create(
              submission_params.merge(question_id: key, value: value[:value], comment: value[:comment])
            )

            if value[:attachfiles].present?
              process_attachments(value[:attachfiles], "Question-#{key}", @submission.id)
            end
          end
        end

        if params[:questions_arr].present?
          params[:questions_arr].each do |key, value|
            @submission = Submission.create(
              submission_params.merge(question_id: value[:id], value: value[:option])
            )
            puts @submission.errors
          end
        end
      end

      respond_to do |format|
        if @submission.save
          #binding.pry
          if params[:attachfiles].present?
            params[:attachfiles].each do |doc|
              Attachfile.create(
                image: doc,
                relation: "SubmissionDocuments",
                relation_id: @submission.id,
                active: 1
              )
            end
          end
          # @submission.activity.update(status: "complete") if @submission.activity.present?
          if @submission.activity.present?
            @submission.activity.status = "complete"
            @submission.activity.save(validate: false)
          end

          format.html { redirect_to @submission, notice: "Submission was successfully created." }
          format.json { render :show, status: :created, location: @submission }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @submission.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  private

  def process_attachments(attachfiles, relation, relation_id)
    files = attachfiles.is_a?(Array) ? attachfiles : [attachfiles]
    files.each do |file|
      if file.is_a?(ActionDispatch::Http::UploadedFile)
        Attachfile.create(
          image: file,
          relation: relation,
          relation_id: relation_id,
          active: 1
        )
      elsif file.is_a?(String) && file.start_with?('data:image')
        file_path = file.include?('image/png') ? Attachfile.createpng(file) : Attachfile.createimage(file)
        Attachfile.create(
          image: File.open(file_path),
          relation: relation,
          relation_id: relation_id,
          active: 1
        )
        File.delete(file_path) if File.exist?(file_path)
      end
    end
  end


  # PATCH/PUT /submissions/1 or /submissions/1.json
  def update
    respond_to do |format|
      if @submission.update(submission_params)
        format.html { redirect_to @submission, notice: "Submission was successfully updated." }
        format.json { render :show, status: :ok, location: @submission }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @submission.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /submissions/1 or /submissions/1.json
  def destroy
    @submission.destroy
    respond_to do |format|
      format.html { redirect_to submissions_url, notice: "Submission was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_submission
    @submission = Submission.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def submission_params
    params.require(:submission).permit(:asset_id, :checklist_id, :activity_id, :question_id, :value,  :comment, :user_id, :soft_service_id, :patrolling_id)
  end

  # def submission_params
  #   params.require(:submission).permit(:asset_id, :checklist_id, :activity_id, :question_id, :value, :value_type, :comment, :user_id, :soft_service_id, :patrolling_id, questions: [:id, :option, :value_type1, :value_type2, :value_type3, :value_type4])
  # end

  # def update_associated_activities(activity)
  #   return unless activity

  #   associated_activities = Activity.where(
  #     checklist_id: activity.checklist_id,
  #     asset_id: activity.asset_id,
  #     soft_service: activity.soft_service_id
  #     #start_time: activity.start_time,
  #     start_time: activity.start_time.beginning_of_day..activity.start_time.end_of_day,
  #     status: 'pending'
  #   )

  #   associated_activities.update_all(status: 'complete')
  # end

  def update_associated_activities(activity, partially_complete)
    return unless activity

    query_conditions = {
      checklist_id: activity.checklist_id,
      start_time: activity.start_time.beginning_of_day..activity.start_time.end_of_day,
      status: 'pending'
    }

    if activity.soft_service_id.present?
      query_conditions[:soft_service_id] = activity.soft_service_id
    elsif activity.asset_id.present?
      query_conditions[:asset_id] = activity.asset_id
    else
      return
    end

    associated_activities = Activity.where(query_conditions)

    if activity.checklist_id.present? && activity.start_time.present? &&
        (activity.soft_service_id.present? || activity.asset_id.present?)
      checklist = Checklist.find(activity.checklist_id)
      # Check if the grace period is present in the checklist
      if checklist.grace_period_value.present? && checklist.grace_period_unit.present?
        # Calculate the end time based on the grace period
        case checklist.grace_period_unit
        when 'minutes'
          end_time = activity.start_time + checklist.grace_period_value.minutes
        when 'hours'
          end_time = activity.start_time + checklist.grace_period_value.hours
        when 'days'
          end_time = activity.start_time + checklist.grace_period_value.days
        when 'weeks'
          end_time = activity.start_time + checklist.grace_period_value.weeks
        end
      else
        # If the grace period is not present, set end_time to nil
        end_time = nil
      end

      submission = Submission.find_by(activity_id: activity.id)
      if submission.present?
        if end_time && submission.created_at > end_time
          late_minutes = ((submission.created_at - end_time) / 60).round
          associated_activities.update_all(status: "complete (Delay by #{late_minutes} mins) by #{User.find(submission.user_id).full_name}")
          # status = partially_complete ? "partially complete" : "complete"
          # associated_activities.update_all(status: "#{status} (#{late_minutes} mins delay) by #{User.find(submission.user_id).full_name}")
        else
          associated_activities.update_all(status: "complete by #{User.find(submission.user_id).full_name}")
          # status = partially_complete ? "partially complete" : "complete"
          # associated_activities.update_all(status: "#{status} by #{User.find(submission.user_id).full_name}")
        end
      else
        # Handle the case where the submission is not found
        Rails.logger.error "Submission not found for activity #{activity.id}"
      end
    end
  end
end
