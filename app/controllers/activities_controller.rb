class ActivitiesController < ApplicationController
  include UserExt # Assuming this module handles @user setup
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user # Assuming this sets up @user based on API key
  before_action :set_user # Assuming this sets @user, possibly redundant if api_user does it
  before_action :set_activity, only: %i[ show edit update destroy ]
  # update_overdue_activities seems to be commented out or intended for a background job,
  # so I'll keep it commented out, but recommend running it in a scheduled task.
  # before_action :update_overdue_activities, only: [:index]


  # def index
  #   ransack_params = params[:q] || {}
  #   checklist_ids = fetch_checklist_ids

  #   per_page = (params[:per_page] || 100).to_i
  #   page = (params[:page] || 1).to_i

  #   # Step 1: Build base query to get unique activity IDs only
  #   base_query = Activity.joins(:checklist)
  #   .where(checklists: { site_id: @user.current_site_id })

  #   if @user.user_type != 'pms_admin'
  #     base_query = base_query.where(checklists: { active: true, id: checklist_ids })
  #   end

  #   # Step 2: Apply ransack filters and get distinct IDs
  #   filtered_ids = base_query.ransack(ransack_params).result
  #   .select('DISTINCT activities.id, activities.start_time')
  #   .order('activities.start_time ASC, activities.id ASC')

  #   # Apply activity_id filter if present
  #   if params[:activity_id].present?
  #     filtered_ids = filtered_ids.where('activities.id' => params[:activity_id])
  #   end

  #   # Step 3: Get total count before pagination
  #   # @total_count = filtered_ids.count
  #   @total_count = filtered_ids.count('activities.id')
  #   # Step 4: Apply pagination to the IDs
  #   paginated_ids = filtered_ids.limit(per_page)
  #   .offset((page - 1) * per_page)
  #   .pluck(:id)

  #   # Step 5: Fetch the actual records with includes maintaining the order
  #   if paginated_ids.any?
  #     # Create a case statement to preserve the order of IDs
  #     order_clause = paginated_ids.each_with_index.map do |id, index|
  #       "WHEN #{id} THEN #{index}"
  #     end.join(' ')

  #     @activities = Activity.where(id: paginated_ids)
  #     .includes(
  #       :site_asset,
  #       soft_service: [:site, :building, :floor, :unit],
  #       checklist: { checklist_users: :user }
  #     )
  #     .order("CASE activities.id #{order_clause} END")
  #   else
  #     @activities = Activity.none
  #   end

  #   total_pages = @total_count > 0 ? (@total_count.to_f / per_page).ceil : 0


  #   # Create a simple pagination-like object for the view
  #   @activities.define_singleton_method(:current_page) { page }
  #   #  @activities.define_singleton_method(:total_pages) { (@total_count.to_f / per_page).ceil }
  #   @activities.define_singleton_method(:total_pages) { total_pages }
  #   @activities.define_singleton_method(:total_count) { @total_count }
  #   @activities.define_singleton_method(:limit_value) { per_page }
  #   @activities.define_singleton_method(:total_entries) { @total_count }
  # end

  def index
    # Step 1: Initialize ransack params and checklist IDs
    ransack_params = params[:q] || {}
    checklist_ids = fetch_checklist_ids

    # Step 2: Build base query with proper site filtering
    activities_query = build_activities_query(checklist_ids)

    # Step 3: Apply ransack filters and pagination
    activities_query = activities_query.ransack(ransack_params).result(distinct: true)
    activities_query = apply_activity_id_filter(activities_query)

    # Step 4: Eager load associations for better performance
    activities_query = activities_query.includes(
      :site_asset,
      :user,
      soft_service: [:site, :building, :floor],
      checklist: { checklist_users: :user, questions: :hint_attachment }
    )
    @activities = activities_query.order(start_time: :asc).page(params[:page]).per(params[:per_page] || 10)
    # Step 5: Calculate total count efficiently
    @total_count = calculate_total_count(checklist_ids)
    respond_to do |format|
      format.html
      format.json
    end
  end


  def show
    @activity = Activity.includes(
      :checklist,
      :site_asset,
      soft_service: [:site, :building, :floor, :unit],
      checklist: { checklist_users: :user },
      # :assigned_user # Uncomment if needed
    ).find(params[:id])
  end

  # GET /activities/new
  def new
    @activity = Activity.new
    @checklist_id = params[:checklist_id]
  end

  # GET /activities/1/edit
  def edit
  end


  def checklist_associations
    acts = Activity.includes(:soft_service, :site_asset, checklist: { checklist_users: :user })
    .where(checklist_id: params[:checklist_id])
    .select(:id, :soft_service_id, :assigned_to, :asset_id, :patrolling_id, :checklist_id)

    #  page = params[:page] || 1
    #  per_page = params[:per_page] || 100

    pagination_activities = acts.page(params[:page]).per_page(params[:per_page] || 12500)

    mapped_data = pagination_activities.map do |activity|
      resource_type = activity.asset_id.present? ? 'SiteAsset' : 'SoftService'
      resource_id = activity.asset_id || activity.soft_service_id

      # No DB query here, use preloaded checklist_users
      checklist_users = activity.checklist.checklist_users.select do |cu|
        cu.resource_type == resource_type && cu.resource_id == resource_id
      end

      if checklist_users.present?
        assigned_users = checklist_users.map { |cu| cu.user&.full_name.to_s.strip }
        assigned_user_ids = checklist_users.map(&:user_id)
      else
        # Fallback: use assigned_to from activity
        user_ids = if activity.assigned_to.is_a?(String)
          activity.assigned_to.split(',').map(&:strip).map(&:to_i)
        else
          Array(activity.assigned_to).map(&:to_i)
        end

        users_hash = User.where(id: user_ids).index_by(&:id)

        assigned_users = user_ids.map { |id| users_hash[id]&.full_name.to_s.strip }
        assigned_user_ids = user_ids
      end

      {
        id: activity.id,
        service_name: activity.soft_service&.name.to_s.strip,
        asset_id: activity.asset_id,
        asset_name: activity.site_asset&.name.to_s.strip,
        assigned_to: assigned_users,
        assigned_to_ids: assigned_user_ids
      }
    end

    # Group by asset_id + service_name + asset_name
    grouped_data = mapped_data.group_by { |item| [item[:asset_id], item[:service_name], item[:asset_name]] }

    unique_combined = grouped_data.map do |(asset_id, service_name, asset_name), group_items|
      all_assigned_users = group_items.flat_map { |item| item[:assigned_to] }.uniq.sort
      all_assigned_ids = group_items.flat_map { |item| item[:assigned_to_ids] }.uniq.sort

      assigned_with_index = all_assigned_users.each_with_index.map do |user, index|
        {
          index: index,
          user_name: user,
          user_id: all_assigned_ids[index]
        }
      end

      {
        asset_id: asset_id,
        asset_name: asset_name,
        service_name: service_name,
        assigned_to: all_assigned_users.join(', '),
        users_with_ids: assigned_with_index
      }
    end

    # Apply sorting and limit
    unique_combined = unique_combined.sort_by { |d| d[:service_name].to_s.downcase }

    render json: { associated_with: unique_combined }
  end



  def count
    site_ids_param = params[:site_ids].present? ? params[:site_ids].split(",") : [@user.selected_site_id].compact # Ensure it's an array
    activities_scope = Activity.joins(:checklist)
    .where(checklists: { site_id: site_ids_param })
    if @user.user_type != 'pms_admin'
      activities_scope = activities_scope.joins(checklist: :checklist_users)
      .where(checklist_users: { user_id: @user.id })
    end
    activities_query = activities_scope.ransack(params[:q]).result(distinct: true)
    @activities_count = if params[:scheduled].present?
      activities_query.where(status: ["pending", "overdue", "complete"]).count
    elsif params[:complete].present?
      activities_query.where(status: "complete").count
    elsif params[:pending].present?
      activities_query.where(status: "pending").count
    elsif params[:overdue].present?
      activities_query.where(status: "overdue").count
    else
      activities_query.count
    end

    respond_to do |format|
      format.json {
        render json: { count: @activities_count }
      }
    end
  end

  def calendar_data
    site_ids_for_calendar = params[:site_ids].present? ? params[:site_ids].split(",") : [@user.current_site_id].compact
    activities = Activity.joins(:checklist).where(checklists: { site_id: site_ids_for_calendar }).ransack(params[:q]).result(distinct: true).includes(:user, :checklist, checklist_users: :user) # Eager load checklist for its name

    if params[:startdate].present? && params[:enddate].present?
      start_date_parsed = Date.parse(params[:startdate]) rescue nil
      end_date_parsed = Date.parse(params[:enddate]) rescue nil
      if start_date_parsed && end_date_parsed
        activities = activities.where(start_time: start_date_parsed.beginning_of_day..end_date_parsed.end_of_day)
      end
    end
    events = activities.map do |activity|
      {
        id: activity.id,
        title: activity.checklist.name,
        start: activity.start_time.strftime("%Y-%m-%d"),
        start_time: activity.start_time.strftime("%H:%M:%S"),
        status: activity&.status,
        end: activity.end_time.try(:strftime, "%Y-%m-%d %H:%M:%S"),
        assigned_users: activity.checklist_users.map {|u| u.user&.full_name}.compact.uniq.presence || [activity.user&.full_name]
      }
    end
    render json: events
  end

  def routine_task_counts
    site_id = @user.current_site_id
    base_scope = Activity.joins(:checklist).where(checklists: { ctype: 'routine', site_id: site_id })
    @counts = base_scope.group(:status).count
    filtered_activities = base_scope
    # Check if filters are applied
    filters_applied = params[:q].present? && (
      params[:q][:status_eq].present? ||
      params[:q][:start_time_gteq].present? ||
      params[:q][:start_time_lteq].present?
    )
    if params[:q].present?
      q = params[:q]
      # Apply status filter
      filtered_activities = filtered_activities.where(status: q[:status_eq]) if q[:status_eq].present?

      # Apply date range filters
      if q[:start_time_gteq].present?
        filtered_activities = filtered_activities.where("activities.start_time >= ?", Date.parse(q[:start_time_gteq]).beginning_of_day)
      end
      if q[:start_time_lteq].present?
        filtered_activities = filtered_activities.where("activities.start_time <= ?", Date.parse(q[:start_time_lteq]).end_of_day)
      end
    end

    # Default filter: if no filter applied, show from beginning of today
    unless filters_applied
      filtered_activities = filtered_activities.where("activities.start_time >= ?", Time.zone.now.beginning_of_day)
    end

    @activities = filtered_activities
    .includes(
      checklist: [:users],
      soft_service: [:site, :building, :floor],
      site_asset: [:site, :building, :floor]
    )
    .order(:start_time)
    #.limit(100)

    respond_to do |format|
      format.json { render 'routine_task_counts' }
    end
  end

  def export
    # First filter to get matching IDs (without includes to avoid JOIN/DISTINCT conflicts)
    filtered_ids = apply_export_filters(Activity.all).pluck(:id)

    # Then load full records with eager-loaded associations
    @activities = Activity.where(id: filtered_ids)
      .includes(
        :checklist,
        :soft_service,
        :site_asset,
        :user,
        checklist: { checklist_users: :user }
      )
      .order(start_time: :desc)

    respond_to do |format|
      format.xlsx do
        response.headers['Content-Disposition'] =
          'attachment; filename="activities.xlsx"'
      end
    end
  end

  def export_routine
    site_id = @user.current_site_id
    base_scope = Activity.joins(:checklist)
      .where(checklists: { ctype: 'routine', site_id: site_id })

    if params[:q].present?
      q = params[:q]
      base_scope = base_scope.where(status: q[:status_eq]) if q[:status_eq].present?

      if q[:start_time_gteq].present?
        base_scope = base_scope.where("activities.start_time >= ?", Date.parse(q[:start_time_gteq]).beginning_of_day)
      end
      if q[:start_time_lteq].present?
        base_scope = base_scope.where("activities.start_time <= ?", Date.parse(q[:start_time_lteq]).end_of_day)
      end
    end

    filtered_ids = base_scope.pluck(:id)

    @activities = Activity.where(id: filtered_ids)
      .includes(:checklist, :soft_service, :site_asset, submissions: :user, checklist: :users)
      .order(start_time: :desc)

    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = 'attachment; filename="activities.xlsx"'
      }
    end
  end

  # POST /activities or /activities.json
  def create
    checklist = Checklist.unscoped.find_by(id: params[:activity][:checklist_id])

    unless checklist
      # Handle case where checklist is not found
      return respond_to do |format|
        format.html { redirect_to new_activity_path, alert: "Checklist not found." }
        format.json { render json: { error: "Checklist not found" }, status: :unprocessable_entity }
      end
    end

    timings = checklist.set_timings
    puts "Timings for checklist: #{timings.inspect}"

    activities_to_create = []
    checklist_users_to_create = []


    if params[:asset_ids].present?
      params[:asset_ids].each do |aid|
        timings.each do |tm|
          activities_to_create << {
            asset_id: aid,
            checklist_id: checklist.id,
            start_time: tm,
            status: "pending"
          }
        end

        params[:assigned_to].each do |assignee|
          checklist_users_to_create << {
            checklist_id: checklist.id,
            user_id: assignee,
            resource_id: aid,
            resource_type: "SiteAsset"
          }
        end
      end
    end

    if params[:soft_service_ids].present?
      params[:soft_service_ids].each do |sid|
        timings.each do |tm|
          activities_to_create << {
            soft_service_id: sid,
            checklist_id: checklist.id,
            start_time: tm,
            status: "pending"
          }
        end

        params[:assigned_to].each do |assignee|
          checklist_users_to_create << {
            checklist_id: checklist.id,
            user_id: assignee,
            resource_id: sid,
            resource_type: "SoftService"
          }
        end
      end
    end


    # Patrolling create
    if params[:patrolling_ids].present?
      params[:patrolling_ids].each do |pid|
        params[:assigned_to].each do |assignee|
          timings.each do |tm|
            activities_to_create << { patrolling_id: pid, checklist_id: checklist.id, start_time: tm, status: "pending", assigned_to: assignee }
          end
        end
      end
    end

    success = true
    errors = []

    ActiveRecord::Base.transaction do
      if activities_to_create.any?
        activities_to_create.each do |act_data|
          activity = Activity.new(act_data)
          unless activity.save
            success = false
            errors += activity.errors.full_messages
            raise ActiveRecord::Rollback
          end
        end
      end
      if success && checklist_users_to_create.any?
        checklist_users_to_create = checklist_users_to_create.uniq do |cu|
          [cu[:checklist_id], cu[:user_id], cu[:resource_id], cu[:resource_type]]
        end

        checklist_users_to_create.each do |check_create|
          checklist_user = ChecklistUser.new(check_create)
          unless checklist_user.save
            success = false
            errors += checklist_user.errors.full_messages
            raise ActiveRecord::Rollback
          end
        end
      end
    end

    respond_to do |format|
      if success
        format.html { redirect_to "/checklists", notice: "Activities were successfully created." }
        format.json { render json: { message: "Activities created successfully" }, status: :created }
      else
        # Handle the error, maybe render new form with errors
        @activity = Activity.new(activity_params) # Re-initialize for rendering form
        @checklist_id = params[:activity][:checklist_id]
        format.html { render :new, status: :unprocessable_entity, alert: "Failed to create some activities." }
        format.json { render json: {error:  errors }, status: :unprocessable_entity }
      end
    end
  end

  def update
    @activity = Activity.find(params[:id])

    if @activity.update(activity_params)
      render json: { message: 'Activity updated successfully' }, status: :ok
    else
      render json: { errors: @activity.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def bulk_update
    asset_ids = params[:asset_ids] || []
    soft_service_ids = params[:soft_service_ids] || []
    assignees = (params[:assigned_to] || []).map(&:to_i)
    checklist_id = params[:activity]&.dig(:checklist_id)&.to_i || params[:checklist_id].to_i

    checklist = Checklist.find(checklist_id)
    checklist_cron = ChecklistCron.find_by(checklist_id: checklist.id)
    timings = checklist_cron.present? ? [Fugit::Cron.parse(checklist_cron.expression).next_time.to_time_s] : [Time.now]
    success = true
    errors = []

    ActiveRecord::Base.transaction do
      # Handle Assets
      asset_ids.each do |aid|
        ### STEP 1 — Clean up ChecklistUsers not present anymore
        ChecklistUser.where(
          checklist_id: checklist_id,
          resource_id: aid,
          resource_type: "SiteAsset"
        ).where.not(user_id: assignees).delete_all

        ### STEP 2 — Create missing ChecklistUsers
        assignees.each do |assignee|
          ChecklistUser.find_or_create_by!(
            checklist_id: checklist_id,
            user_id: assignee,
            resource_id: aid,
            resource_type: "SiteAsset"
          )
        end

        ### STEP 3 — Clean up Activities
        existing_activities = Activity.where(checklist_id: checklist_id, asset_id: aid).where.not(assigned_to: nil)
        existing_user_ids = existing_activities.pluck(:assigned_to).map(&:to_i)

        users_to_delete = existing_user_ids - assignees

        if users_to_delete.any?
          Activity.where(
            checklist_id: checklist_id,
            asset_id: aid,
            assigned_to: users_to_delete
          ).delete_all
        end

        ### STEP 4 — Create missing Activities
        assignees.each do |assignee|
          activity = Activity.find_or_initialize_by(
            asset_id: aid,
            checklist_id: checklist_id,
            assigned_to: assignee
          )

          if activity.new_record?
            activity.start_time = timings.first
            activity.status = "pending"
            activity.save!
          end
        end
      end

      # Handle Soft Services
      soft_service_ids.each do |sid|
        ### STEP 1 — Clean up ChecklistUsers not present anymore
        ChecklistUser.where(
          checklist_id: checklist_id,
          resource_id: sid,
          resource_type: "SoftService"
        ).where.not(user_id: assignees).delete_all

        ### STEP 2 — Create missing ChecklistUsers
        assignees.each do |assignee|
          ChecklistUser.find_or_create_by!(
            checklist_id: checklist_id,
            user_id: assignee,
            resource_id: sid,
            resource_type: "SoftService"
          )
        end

        ### STEP 3 — Clean up Activities
        existing_activities = Activity.where(checklist_id: checklist_id, soft_service_id: sid).where.not(assigned_to: nil)
        existing_user_ids = existing_activities.pluck(:assigned_to).map(&:to_i)

        users_to_delete = existing_user_ids - assignees

        if users_to_delete.any?
          Activity.where(
            checklist_id: checklist_id,
            soft_service_id: sid,
            assigned_to: users_to_delete
          ).delete_all
        end

        ### STEP 4 — Create missing Activities
        assignees.each do |assignee|
          activity = Activity.find_or_initialize_by(
            soft_service_id: sid,
            checklist_id: checklist_id,
            assigned_to: assignee
          )

          if activity.new_record?
            activity.start_time = timings.first
            activity.status = "pending"
            activity.save!
          end
        end
      end
    rescue => e
      success = false
      errors << e.message
      raise ActiveRecord::Rollback
    end

    if success
      render json: { message: "Activities successfully updated" }
    else
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end



  def delete_act
    # Optimized to use `in` for multiple assigned_to if it's an array
    checklist_id = params[:checklist_id]
    assigned_to_ids = params[:assigned_to].present? ? params[:assigned_to].split(',') : nil
    asset_id = params[:asset_id]
    soft_service_id = params[:soft_service_id]
    patrolling_id = params[:patrolling_id]

    activities_to_delete = Activity.where(checklist_id: checklist_id)
    activities_to_delete = activities_to_delete.where(assigned_to: assigned_to_ids) if assigned_to_ids.present?
    activities_to_delete = activities_to_delete.where(asset_id: asset_id) if asset_id.present?
    activities_to_delete = activities_to_delete.where(soft_service_id: soft_service_id) if soft_service_id.present?
    activities_to_delete = activities_to_delete.where(patrolling_id: patrolling_id) if patrolling_id.present?

    deleted_count = activities_to_delete.delete_all # delete_all is faster as it bypasses callbacks

    flash[:notice] = "Successfully deleted #{deleted_count} activities."

    redirect_to new_activity_path(checklist_id: checklist_id)
  end

  # DELETE /activities/1 or /activities/1.json
  def destroy
    group_scope = Activity.where(checklist_id: @activity.checklist_id)

    if @activity.asset_id.present?
      group_scope = group_scope.where(asset_id: @activity.asset_id)
    elsif @activity.soft_service_id.present?
      group_scope = group_scope.where(soft_service_id: @activity.soft_service_id)
    end

    group_scope = group_scope.where(assigned_to: @activity.assigned_to)

    destroyed_count = group_scope.destroy_all.count

    respond_to do |format|
      format.html { redirect_to activities_url, notice: "#{destroyed_count} grouped activities were successfully destroyed." }
      format.json { render json: { message: "#{destroyed_count} activities deleted." }, status: :ok }
    end
  end


  def bulk_destroy
    checklist_id = params[:checklist_id].to_i
    asset_id = params[:asset_id].presence
    soft_service_id = params[:soft_service_id].presence

    destroyed_activity_count = 0
    destroyed_user_count = 0

    today = Date.current

    ActiveRecord::Base.transaction do
      if asset_id.present?
        # ASSET → delete all (unchanged)
        activity_scope = Activity.where(
          checklist_id: checklist_id,
          asset_id: asset_id
        )

        destroyed_activity_count = activity_scope.delete_all

        user_scope = ChecklistUser.where(
          checklist_id: checklist_id,
          resource_type: "SiteAsset",
          resource_id: asset_id
        )

        destroyed_user_count = user_scope.delete_all

      elsif soft_service_id.present?
        # SOFT SERVICE → delete only today + future
        activity_scope = Activity.where(
          checklist_id: checklist_id,
          soft_service_id: soft_service_id
        ).where("start_time >= ?", today)

        destroyed_activity_count = activity_scope.delete_all

        # ⚠️ Usually checklist_users has no date
        # Only delete users if NO future activities exist
        remaining_future = Activity.where(
          checklist_id: checklist_id,
          soft_service_id: soft_service_id
        ).where("start_time >= ?", today).exists?

        unless remaining_future
          user_scope = ChecklistUser.where(
            checklist_id: checklist_id,
            resource_type: "SoftService",
            resource_id: soft_service_id
          )
          destroyed_user_count = user_scope.delete_all
        end
      end
    end

    render json: {
      message: "#{destroyed_activity_count} future activities deleted. #{destroyed_user_count} users removed."
    }, status: :ok
  end




  private

  # Common query scope for activities based on user type and site
  def base_scoped_activities(site_ids_param)
    scope = Activity.joins(:checklist).where(checklists: { site_id: site_ids_param })
    unless @user.user_type == 'pms_admin'
      scope = scope.joins(checklist: :checklist_users)
      .where(checklist_users: { user_id: @user.id })
      .where(checklists: { active: true }) # Added active: true for non-admins consistently
    end
    scope
  end


  # New

  def fetch_checklist_ids
    return nil if @user.user_type == 'pms_admin'
    ChecklistUser.where(user_id: @user.id).select(:checklist_id).distinct
  end

  def build_activities_query(checklist_ids)
    # Ensure we use the user's selected site, fallback to current_site_id
    site_id = @user.selected_site_id.presence || @user.current_site_id

    # Base query with checklist site filter
    query = Activity.joins(:checklist)
    .where(checklists: { site_id: site_id })

    # Add left joins for soft_services and site_assets to filter by site
    query = query.left_joins(:soft_service, :site_asset, :user)
    .where('(activities.soft_service_id IS NULL OR soft_services.site_id = ?) AND (activities.asset_id IS NULL OR site_assets.site_id = ?)', site_id, site_id)

    if @user.user_type != 'pms_admin'
      query = query.where(checklists: { active: true, id: checklist_ids })
    end

    query
  end

  def apply_activity_id_filter(query)
    return query unless params[:activity_id].present?
    query.where(id: params[:activity_id])
  end

  def calculate_total_count(checklist_ids)
    # Ensure we use the user's selected site, fallback to current_site_id
    site_id = @user.selected_site_id.presence || @user.current_site_id

    if @user.user_type == 'pms_admin'
      Activity.joins(:checklist)
      .where(checklists: { site_id: site_id })
      .distinct.count(:id)
    else
      Activity.joins(:checklist)
      .where(checklist_id: checklist_ids)
      .where(checklists: { site_id: site_id })
      .distinct.count(:id)
    end
  end

  # Applies filters for count and export actions
  # Uses the same site-only scoping as site_assets_dashboard so counts match.
  def apply_export_filters(query_scope)
    site_ids = params[:site_ids].present? ? params[:site_ids].split(",") : @user.current_site_id

    activities = query_scope
    .joins(:checklist)
    .where(checklists: { site_id: site_ids })
    .ransack(params[:q])
    .result(distinct: true)

    # Date filters — only applied when explicitly provided.
    # Without explicit dates, return all matching records (consistent with dashboard).
    # Support both start_time/end_time and start_date/end_date param names.
    start_date = parse_activity_date(params[:start_time].presence || params[:start_date]) || params[:start_time_gteq]
    end_date   = parse_activity_date(params[:end_time].presence || params[:end_date]) || params[:start_time_lteq]

    if start_date && end_date
      activities = activities.where(
        start_time: start_date.beginning_of_day..end_date.end_of_day
      )
    elsif start_date
      activities = activities.where("start_time >= ?", start_date.beginning_of_day)
    elsif end_date
      activities = activities.where("start_time <= ?", end_date.end_of_day)
    end

    # Status filters
    if params[:scheduled].present?
      activities = activities.where(status: "pending")
    elsif params[:complete].present?
      activities = activities.where(status: "complete")
    elsif params[:pending].present?
      activities = activities.where(status: "pending")
    elsif params[:overdue].present?
      activities = activities.where(status: "overdue")
    end

    activities
  end

  def set_activity
    @activity = Activity.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def activity_params
    params.require(:activity).permit(:patrolling_id, :asset_id, :checklist_id, :start_time, :end_time, :status, :assigned_to)
  end

  def parse_activity_date(value)
    return nil if value.blank?
    # format differ from params date ...........
    formats = ["%d/%m/%Y", "%Y-%m-%d", "%d-%m-%Y", "%m/%d/%Y", "%m-%d-%Y"]
    formats.each do |fmt|
      return Date.strptime(value, fmt)
    rescue Date::Error
      next
    end

    # Final fallback
    Date.parse(value) rescue nil
  end
end
