class SiteAssetsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user, except: [:print_qr_codes, :download_sample]
  before_action :api_user, except: [:print_qr_codes, :download_sample]
  before_action :set_user, except: [:print_qr_codes, :download_sample]
  before_action :set_site_asset, only: %i[show edit update destroy asset_ppm_show]
  # skip_before_action :set_site_asset, only: [:print_qr_codes]

  # GET /site_assets or /site_assets.json
  def index
    base_query = SiteAsset.where(site_id: @user.current_site_id).left_joins(:building, :floor, :unit, :user).ransack(params[:q]).result.order(created_at: :desc)
    base_query = base_query.where(is_meter: true) if params.dig(:q, :is_meter) == 'true'
    case params[:card_filter]
    when 'in_use'
      base_query = base_query.where(breakdown: false)
    when 'breakdown'
      base_query = base_query.where(breakdown: true)
    when 'activities_performed'
      asset_ids_with_activities = Activity.joins(:checklist)
      .where(status: 'complete')
      .where.not(asset_id: nil)
      .distinct
      .pluck(:asset_id)
      base_query = base_query.where(id: asset_ids_with_activities)
    when 'ppm_performed'
      asset_ids_with_ppm = Activity.joins(:checklist)
      .where(checklists: { ctype: 'ppm' })
      .where(status: 'complete')
      .where.not(asset_id: nil)
      .distinct
      .pluck(:asset_id)
      base_query = base_query.where(id: asset_ids_with_ppm)
    when 'amc_performed'
      # Assets that have completed AMC activities
      asset_ids_with_amc = Activity.joins(:checklist)
      .where(checklists: { ctype: 'amc' })
      .where(status: 'complete')
      .where.not(asset_id: nil)
      .distinct
      .pluck(:asset_id)
      base_query = base_query.where(id: asset_ids_with_amc)
    end

    @total_count = base_query.count

    # if params[:page].present? || params[:per_page].present?
    @site_assets = base_query.page(params[:page]).per(params[:per_page] || 1000)
    # =begin=beginelse
    #   @site_assets = base_query
    # end=end=end

    # eager load heavy associations AFTER filtering
    @site_assets = @site_assets.includes(
      :building,
      :floor,
      :unit,
      :vendor,
      :parent_asset,
      :asset_group,
      :sub_group,
      :asset_params,
      :qr_code_image,
      :purchase_invoices,
      :insurances,
      :manuals,
      :other_files
    )
  end

  def qr_codes
    @site_assets = SiteAsset.where(site_id: @user.current_site_id)
    render pdf: 'qr_codes',
      disposition: 'attachment',
      dpi: 72,
      template: 'site_assets/qr_codes.html',
      # layout: 'layouts/pdf.html.erb',
      formats: :pdf,
      encoding: 'utf8'
    return
  end

  def count
    site_id = params[:site_ids].present? ? params[:site_ids].split(",") : @user.selected_site_id

    @site_assets = SiteAsset.where(site_id: site_id).order("created_at  DESC").ransack(params[:q]).result

    asset_count = @site_assets.count
    asset_in_user =

    respond_to do |format|
      format.json {
        render json: { count: asset_count }
      }
    end
  end
  # for single and multiple
  # def print_qr_codes
  #   @site_assets = if params[:asset_ids].present?
  #     SiteAsset.where(id: params[:asset_ids].split(","))
  #   else
  #     SiteAsset.where(id: params[:asset_ids])
  #   end
  #   render pdf: 'qr_codes',
  #          disposition: 'attachment',
  #          dpi: 72,
  #          template: 'site_assets/qr_codes.html',
  #          # layout: 'layouts/pdf.html.erb',
  #          formats: :pdf,
  #          encoding: 'utf8'
  #   return

  # end
  def print_qr_codes
    asset_ids = params[:asset_ids].to_s.split(",")
    @site_assets = SiteAsset.includes(:site, :building, :floor, :unit, :qr_code_image)
    .where(id: asset_ids)
    render pdf: 'qr_codes',
      disposition: 'attachment',
      dpi: 72,
      template: 'site_assets/qr_codes.html',
      formats: :pdf,
      encoding: 'utf8'
  end

  # GET /site_assets/1 or /site_assets/1.json
  def show
    now = Time.zone.now
    today_range = now.all_day
    @site_asset = SiteAsset.includes(
      :building, :floor, :unit, :vendor,
      :parent_asset, :asset_group, :sub_group,
      :asset_params, :qr_code_image,
      :purchase_invoices, :insurances,
      :manuals, :other_files,
      tickets: [],
      activities: {
        site_asset: [:building, :floor, :unit, :site],
        # units: [],
        site: [],
        # building: [],
        # floor: [],
        checklist: {
          users: [],
          questions: [:group, :hint_attachment]
        }
      }
    ).find(params[:id])

    @tickets = @site_asset.tickets
    load_ppm_data
    @now = now
    @today_range = today_range
  end

  # GET /site_assets/new
  def new
    @site_asset = SiteAsset.new
  end

  # GET /site_assets/1/edit
  def edit
  end

  # POST /site_assets or /site_assets.json
  def create
    @site_asset = SiteAsset.new(site_asset_params)
    if params[:token].present?
      user = User.find_by(api_key: params[:token])
      @site_asset.user_id = user.id
    end
    respond_to do |format|
      if @site_asset.save
        # if params[:asset_measures].present?
        #   params[:asset_measures].each do |asset_measure|
        #     AssetMeasure.create(asset_id: @site_asset.id,name: asset_measure[:name],min_value: asset_measure[:min_value],max_value: asset_measure[:max_value],alert_below: asset_measure[:alert_below],alert_above: asset_measure[:alert_above],meter_tag: asset_measure[:meter_tag],unit_type: asset_measure[:unit_type])
        #   end
        # end
        if params[:asset_params].present?
          params[:asset_params].each do |asset_param|
            AssetParam.create(asset_id: @site_asset.id, name: asset_param[:name], param_type: asset_param[:param_type], dashboard_view: asset_param[:dashboard_view], consumption_view: asset_param[:consumption_view], order: asset_param[:order], digit: asset_param[:digit], alert_below: asset_param[:alert_below], alert_above: asset_param[:alert_above], min_val: asset_param[:min_val], max_val: asset_param[:max_val], check_prev: asset_param[:check_prev], unit_type: asset_param[:unit_type], multiplier_factor: asset_param[:multiplier_factor])
          end
        end
        if params[:purchase_invoices].present?
          params[:purchase_invoices].each do |doc|
            Attachfile.create(image: doc, relation: "AssetPurchaseInvoice", relation_id: @site_asset.id, active: 1)
          end
        end
        if params[:insurances].present?
          params[:insurances].each do |doc|
            Attachfile.create(image: doc, relation: "AssetInsurance", relation_id: @site_asset.id, active: 1)
          end
        end
        if params[:manuals].present?
          params[:manuals].each do |doc|
            Attachfile.create(image: doc, relation: "AssetManual", relation_id: @site_asset.id, active: 1)
          end
        end
        if params[:other_files].present?
          params[:other_files].each do |doc|
            Attachfile.create(image: doc, relation: "AssetOther", relation_id: @site_asset.id, active: 1)
          end
        end
        format.html { redirect_to "/site_assets", notice: "Site asset was successfully created." }
        # format.json { render :show, status: :created, location: @site_asset }
        format.json { redirect_to site_asset_url(@site_asset, format: :json) }
      else
        puts @site_asset.errors.full_messages.join(', ')
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @site_asset.errors, alert: @site_asset.errors.full_messages.join(', ') }
      end
    end
  end

  # PATCH/PUT /site_assets/1 or /site_assets/1.json
  def update
    respond_to do |format|
      if params[:asset_params].present?
        params[:asset_params].each do |asset_param|
          if asset_param[:id].present?
            # Update existing asset_param
            existing_param = AssetParam.find(asset_param[:id])
            existing_param.update(name: asset_param[:name],param_type: asset_param[:param_type],dashboard_view: asset_param[:dashboard_view],consumption_view: asset_param[:consumption_view],order: asset_param[:order],digit: asset_param[:digit],alert_below: asset_param[:alert_below],alert_above: asset_param[:alert_above],min_val: asset_param[:min_val],max_val: asset_param[:max_val], check_prev: asset_param[:check_prev], unit_type: asset_param[:unit_type],multiplier_factor: asset_param[:multiplier_factor])
          else
            # Create new asset_param
            AssetParam.create( asset_id: @site_asset.id, name: asset_param[:name], param_type: asset_param[:param_type], dashboard_view: asset_param[:dashboard_view], consumption_view: asset_param[:consumption_view], order: asset_param[:order], digit: asset_param[:digit], alert_below: asset_param[:alert_below], alert_above: asset_param[:alert_above], min_val: asset_param[:min_val], max_val: asset_param[:max_val], check_prev: asset_param[:check_prev], unit_type: asset_param[:unit_type], multiplier_factor: asset_param[:multiplier_factor])
          end
        end
      end
      if params[:purchase_invoices].present?
        params[:purchase_invoices].each do |doc|
          Attachfile.create(image: doc, relation: "AssetPurchaseInvoice", relation_id: @site_asset.id, active: 1)
        end
      end
      if params[:insurances].present?
        params[:insurances].each do |doc|
          Attachfile.create(image: doc, relation: "AssetInsurance", relation_id: @site_asset.id, active: 1)
        end
      end
      if params[:manuals].present?
        params[:manuals].each do |doc|
          Attachfile.create(image: doc, relation: "AssetManual", relation_id: @site_asset.id, active: 1)
        end
      end
      if params[:other_files].present?
        params[:other_files].each do |doc|
          Attachfile.create(image: doc, relation: "AssetOther", relation_id: @site_asset.id, active: 1)
        end
      end
      if @site_asset.update(site_asset_params)
        load_ppm_data
        format.html { redirect_to @site_asset, notice: "Site asset was successfully updated." }
        format.json { render :show, status: :ok, location: @site_asset }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @site_asset.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /site_assets/1 or /site_assets/1.json
  def destroy
    Submission.where(asset_id: @site_asset.id).delete_all
    Activity.where(asset_id: @site_asset.id).delete_all
    AssetParam.where(asset_id: @site_asset.id).delete_all
    @site_asset.destroy
    respond_to do |format|
      format.html { redirect_to site_assets_url, notice: "Site asset was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def export
    @site_assets = SiteAsset.where(site_id: @user.current_site_id).order("created_at DESC").ransack(params[:q]).result
    @site_assets = @site_assets.where(is_meter: true) if params[:q] && params[:q][:is_meter] == 'true'

    start_date = parse_export_date(params[:start_time])
    end_date   = parse_export_date(params[:end_time])

    if start_date && end_date
      @site_assets = @site_assets.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
    elsif start_date
      @site_assets = @site_assets.where("created_at >= ?", start_date.beginning_of_day)
    elsif end_date
      @site_assets = @site_assets.where("created_at <= ?", end_date.end_of_day)
    end

    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = 'attachment; filename="site_assets.xlsx"'
      }
    end
  end

  def grouped_assets_status
    grouped_data = SiteAsset.where(site_id:@user.current_site_id).joins(:asset_group)
    .select("asset_groups.name AS group_name,
                                     COUNT(site_assets.id) AS total_assets,
                                     SUM(CASE WHEN site_assets.warranty_expiry IS NOT NULL AND site_assets.warranty_expiry < CURRENT_DATE THEN 1 ELSE 0 END) AS expired_assets,
                                     SUM(CASE WHEN site_assets.warranty_expiry IS NOT NULL AND site_assets.warranty_expiry >= CURRENT_DATE THEN 1 ELSE 0 END) AS under_warranty_assets,
                                     SUM(CASE WHEN site_assets.breakdown = TRUE THEN 1 ELSE 0 END) AS breakdown_assets,
                                     SUM(CASE WHEN site_assets.breakdown = FALSE THEN 1 ELSE 0 END) AS in_use_assets")
    .group("asset_groups.id, asset_groups.name")

    render json: grouped_data
  end


  def import_reading
    spreadsheet = Roo::Spreadsheet.open(params[:upl_file])
    header = spreadsheet.row(1)
    notfound = []
    asset = SiteAsset.find_by(id: params[:asset_id])
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      act = Activity.create(asset_id: params[:asset_id], start_time: row["actualtime"], status: "complete", assigned_to: 2)
      asset.asset_params.each do |ap|
        if row[ap.name].present?
          Submission.create(asset_id: params[:asset_id], activity_id: act.id, value: row[ap.name], user_id: 2, asset_param_id: ap.id)
        end
      end
    end
    redirect_to "/site_assets/#{asset.id}"
  end

  def download_sample
    file_path = Rails.root.join('public', 'sample_files', 'import_site_assets.xlsx')

    if File.exist?(file_path)
      send_file(
        file_path,
        filename: "import_site_assets.xlsx",
        type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      )
    else
      render json: { error: "Sample file not found" }, status: :not_found
    end
  end

  def import
    @file = params[:file]
    @uploadds = SiteAsset.import(@file, @user)
    respond_to do |format|
      format.html {
        fallback_url = site_assets_path
        redirect_url = request.referrer.present? ? "#{request.referrer}#" : fallback_url
        redirect_to redirect_url, notice: "Successfully imported Assets"
      }
      format.json { render json: @uploadds }
    end
  end

  def asset_ppm_show
    @site_asset = SiteAsset.find(params[:id])
    @activities = @site_asset.activities.ransack(params[:q]).result.includes(:checklist).where("Date(start_time) <= ?", Date.today).order("start_time DESC").page(params[:page]).per_page(params[:per_page] || 50)

    respond_to do |format|
      format.html
      format.json { render json: asset_ppm_data }
    end
  end

  def download_log_excel
    @activities = Activity.where(asset_id: @site_asset.id)
    .includes(:checklist, :submissions, :user)
    .where("Date(start_time) <= ?", Date.today)
    .order(start_time: :DESC)
    @excel_log_data = prepare_excel_log_data
    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = 'attachment; filename="site_asset_log.xlsx"'
        render xlsx: 'site_asset_log', filename: "site_asset_log.xlsx"
      }
    end
  end

  def download_all_log_excel
    @site_assets = SiteAsset.where(site_id: @user.current_site_id)
    .includes(:site, :building, :floor, :unit, :vendor, :asset_group)
    @excel_log_data = @site_assets.flat_map do |site_asset|
      activities = site_asset.activities
      .includes(:checklist, :submissions, :user)
      .where("Date(start_time) <= ?", Date.today)
      .order(start_time: :DESC)
      prepare_excel_all_log_data(activities, site_asset)
    end
    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = 'attachment; filename="all_site_asset_logs.xlsx"'
        render xlsx: 'all_site_asset_logs', filename: "all_site_asset_logs.xlsx"
      }
    end
  end

  def get_asset_count
    site_id =
    if params[:site_id].present?
      params[:site_id].to_i
    else
      @user.current_site_id
    end

    start_date = params[:start_date].presence&.to_date
    end_date   = params[:end_date].presence&.to_date

    # Base asset counts
    @total_count     = SiteAsset.where(site_id: site_id).count
    @in_use_count    = SiteAsset.where(site_id: site_id, breakdown: false).count
    @breakdown_count = SiteAsset.where(site_id: site_id, breakdown: true).count

    asset_ids = SiteAsset.where(site_id: site_id).pluck(:id)

    # Base activity scope
    activity_scope = Activity.joins(:checklist)
    .where(asset_id: asset_ids)

    # Date filter
    if start_date && end_date
      activity_scope = activity_scope.where(
        start_time: start_date.beginning_of_day..end_date.end_of_day
      )

    elsif start_date
      activity_scope = activity_scope.where(
        start_time: start_date.beginning_of_day..start_date.end_of_day
      )

    elsif end_date
      activity_scope = activity_scope.where(
        start_time: end_date.beginning_of_day..end_date.end_of_day
      )
    end


    # Counts
    @activities_performed_count =
      activity_scope.where(status: 'complete').count

    @ppm_scheduled_count =
      activity_scope.where(checklists: { ctype: ['ppm', 'PPM'] })
    .where(status: 'scheduled')
    .count

    @ppm_overdue_count =
      activity_scope.where(checklists: { ctype: ['ppm', 'PPM'] })
    .where(status: 'overdue')
    .count

    @ppm_complete_count =
      activity_scope.where(checklists: { ctype: ['ppm', 'PPM'] })
    .where(status: 'complete')
    .count

    @routine_task_scheduled =
      activity_scope.where(checklists: { ctype: 'routine' })
    .where(status: 'scheduled')
    .count

    @routine_task_overdue =
      activity_scope.where(checklists: { ctype: 'routine' })
    .where(status: 'overdue')
    .count

    @routine_task_complete =
      activity_scope.where(checklists: { ctype: 'routine' })
    .where(status: 'complete')
    .count

    @amc_performed_count =
      activity_scope.where(checklists: { ctype: 'amc' })
    .where(status: 'complete')
    .count

    render json: {
      total_assets: @total_count,
      assets_in_use: @in_use_count,
      assets_in_breakdown: @breakdown_count,
      ppm_scheduled: @ppm_scheduled_count,
      ppm_overdue: @ppm_overdue_count,
      ppm_complete: @ppm_complete_count,
      activities_performed: @activities_performed_count,
      amc_performed: @amc_performed_count,
      routine_task_scheduled: @routine_task_scheduled,
      routine_task_overdue: @routine_task_overdue,
      routine_task_complete: @routine_task_complete
    }
  end

  # GET /site_assets/site_assets_dashboard
  # Params: site_id, start_date, end_date, count_type, count_value, record_page
  def site_assets_dashboard
    site_id    = params[:site_id].present? ? params[:site_id].to_i : @user.current_site_id
    start_date = params[:start_date].presence&.to_date
    end_date   = params[:end_date].presence&.to_date
    date_range = asset_date_range(start_date, end_date)

    base_scope = SiteAsset.where(site_id: site_id)
    date_scope = date_range ? base_scope.where(created_at: date_range) : base_scope

    count_type  = params[:count_type].to_s.presence
    count_value = params[:count_value].to_s.presence
    record_page = (params[:record_page].presence || 1).to_i

    result = {}

    # ── Activity scope for site (via checklist.site_id, not asset_id) ───────
    asset_ids = date_scope.pluck(:id)

    activity_scope = Activity.joins(:checklist).where(checklists: { site_id: site_id })
    if date_range
      activity_scope = activity_scope.where(start_time: date_range)
    end

    activity_status_counts = activity_scope.group(:status).count

    # ── Top-level counts with drill-down support ────────────────────────────
    top_level_scopes = {
      total_assets:        date_scope,
      assets_in_use:       date_scope.where(breakdown: false),
      assets_in_breakdown: date_scope.where(breakdown: true)
    }

    top_level_scopes.each do |name, scope|
      cnt = scope.count
      key_name = name.to_s

      if count_type == key_name && count_value == key_name
        paginated = scope
          .includes(:building, :floor, :unit, :vendor, :asset_group, :qr_code_image)
          .order(created_at: :desc)
          .page(record_page).per(ASSET_PER_PAGE)
        result[name] = {
          count:        cnt,
          records:      paginated.map { |a| asset_record_details(a) },
          total_pages:  paginated.total_pages,
          current_page: paginated.current_page,
          per_page:     ASSET_PER_PAGE
        }
      else
        result[name] = cnt
      end
    end

    # ── PPM / Routine / Activity counts with drill-down ─────────────────────
    ppm_scope     = activity_scope.where(checklists: { ctype: ['ppm', 'PPM'] })
    routine_scope = activity_scope.where(checklists: { ctype: 'routine' })
    activity_top_level_scopes = {
      ppm_scheduled:          ppm_scope.where(status: 'pending'),
      ppm_overdue:            ppm_scope.where(status: 'overdue'),
      ppm_complete:           ppm_scope.where(status: 'complete'),
      routine_task_scheduled: routine_scope.where(status: 'pending'),
      routine_task_overdue:   routine_scope.where(status: 'overdue'),
      routine_task_complete:  routine_scope.where(status: 'complete'),
      activities_performed:   activity_scope.where(status: 'complete'),
      amc_performed:          activity_scope.where(checklists: { ctype: 'amc' }, status: 'complete')
    }

    activity_top_level_scopes.each do |name, a_scope|
      cnt = a_scope.count
      key_name = name.to_s

      if count_type == key_name && count_value == key_name
        paginated = a_scope
          .includes(:checklist, :site_asset, :user)
          .order(start_time: :desc)
          .page(record_page).per(ASSET_PER_PAGE)
        result[name] = {
          count:        cnt,
          records:      paginated.map { |a| activity_record_details(a) },
          total_pages:  paginated.total_pages,
          current_page: paginated.current_page,
          per_page:     ASSET_PER_PAGE
        }
      else
        result[name] = cnt
      end
    end

    # ── by_building ─────────────────────────────────────────────────────────
    building_counts = date_scope
      .joins(:building)
      .group('buildings.name')
      .count
    result[:by_building] = build_asset_group(
      date_scope.joins(:building), 'building', building_counts,
      ->(scope, val) { scope.where(buildings: { name: val }) },
      count_type, count_value, record_page
    )

    # ── by_floor ────────────────────────────────────────────────────────────
    floor_counts = date_scope
      .joins(:floor)
      .group('floors.name')
      .count
    result[:by_floor] = build_asset_group(
      date_scope.joins(:floor), 'floor', floor_counts,
      ->(scope, val) { scope.where(floors: { name: val }) },
      count_type, count_value, record_page
    )

    # ── by_asset_group ──────────────────────────────────────────────────────
    group_counts = date_scope
      .joins(:asset_group)
      .group('asset_groups.name')
      .count
    result[:by_asset_group] = build_asset_group(
      date_scope.joins(:asset_group), 'asset_group', group_counts,
      ->(scope, val) { scope.where(asset_groups: { name: val }) },
      count_type, count_value, record_page
    )

    # ── by_vendor ───────────────────────────────────────────────────────────
    vendor_counts = date_scope
      .joins("LEFT JOIN vendors ON vendors.id = site_assets.vendor_id")
      .group("COALESCE(NULLIF(vendors.vendor_name,''), 'No Vendor')")
      .count
    result[:by_vendor] = build_asset_group(
      date_scope, 'vendor', vendor_counts,
      ->(scope, val) {
        if val == 'No Vendor'
          scope.where(vendor_id: nil)
        else
          scope.joins("LEFT JOIN vendors ON vendors.id = site_assets.vendor_id")
            .where(vendors: { vendor_name: val })
        end
      },
      count_type, count_value, record_page
    )

    # ── by_asset_type ───────────────────────────────────────────────────────
    type_counts = date_scope
      .group("COALESCE(NULLIF(site_assets.asset_type,''), 'Unspecified')")
      .count
    result[:by_asset_type] = build_asset_group(
      date_scope, 'asset_type', type_counts,
      ->(scope, val) {
        val == 'Unspecified' ? scope.where("site_assets.asset_type IS NULL OR TRIM(site_assets.asset_type) = ''")
          : scope.where(asset_type: val)
      },
      count_type, count_value, record_page
    )

    # ── by_category ─────────────────────────────────────────────────────────
    category_counts = date_scope
      .group("COALESCE(NULLIF(site_assets.category,''), 'general')")
      .count
    result[:by_category] = build_asset_group(
      date_scope, 'category', category_counts,
      ->(scope, val) { scope.where(category: val) },
      count_type, count_value, record_page
    )

    # ── by_group_for ────────────────────────────────────────────────────────
    group_for_counts = date_scope
      .joins(:asset_group)
      .group("COALESCE(NULLIF(asset_groups.group_for,''), 'Unspecified')")
      .count
    result[:by_group_for] = build_asset_group(
      date_scope.joins(:asset_group), 'group_for', group_for_counts,
      ->(scope, val) {
        val == 'Unspecified' ? scope.where("asset_groups.group_for IS NULL OR TRIM(asset_groups.group_for) = ''")
          : scope.where(asset_groups: { group_for: val })
      },
      count_type, count_value, record_page
    )

    # ── by_breakdown ────────────────────────────────────────────────────────
    breakdown_counts = {
      'In Use'    => date_scope.where(breakdown: false).count,
      'Breakdown' => date_scope.where(breakdown: true).count
    }
    result[:by_breakdown] = build_asset_group(
      date_scope, 'breakdown', breakdown_counts,
      ->(scope, val) {
        val == 'Breakdown' ? scope.where(breakdown: true) : scope.where(breakdown: false)
      },
      count_type, count_value, record_page
    )

    # ── by_task_status (with drill-down into activities) ─────────────────────
    result[:by_task_status] = build_activity_group(
      activity_scope, 'task_status', activity_status_counts,
      ->(scope, val) { scope.where(status: val) },
      count_type, count_value, record_page,
      key_transform: ->(k) { k.to_s.presence || 'unknown' }
    )

    # ── by_status_delay ─────────────────────────────────────────────────────
    delay_count = activity_scope.where("activities.status LIKE '%delay%'").count
    non_delay_count = activity_scope.where("activities.status NOT LIKE '%delay%'").count
    delay_counts = { 'Delayed' => delay_count, 'On Time' => non_delay_count }
    result[:by_status_delay] = build_activity_group(
      activity_scope, 'status_delay', delay_counts,
      ->(scope, val) {
        val == 'Delayed' ? scope.where("activities.status LIKE '%delay%'") : scope.where("activities.status NOT LIKE '%delay%'")
      },
      count_type, count_value, record_page
    )
    result[:status_delay_count] = delay_count

    # ── by_assigned_user ────────────────────────────────────────────────────
    assigned_user_counts = activity_scope
      .joins("LEFT JOIN users ON users.id = activities.assigned_to")
      .group("TRIM(CONCAT(COALESCE(users.firstname,''), ' ', COALESCE(users.lastname,'')))")
      .count
    result[:by_assigned_user] = build_activity_group(
      activity_scope, 'assigned_user', assigned_user_counts,
      ->(scope, val) {
        if val == 'Unassigned'
          scope.where("activities.assigned_to IS NULL")
        else
          scope.joins("LEFT JOIN users ON users.id = activities.assigned_to")
            .where("TRIM(CONCAT(COALESCE(users.firstname,''), ' ', COALESCE(users.lastname,''))) = ?", val)
        end
      },
      count_type, count_value, record_page,
      key_transform: ->(k) { k.to_s.strip.presence || 'Unassigned' }
    )

    render json: result
  end

  # GET /site_assets/site_assets_drill
  # Params: site_id, filter_type, filter_value, start_date, end_date, page, per_page
  def site_assets_drill
    site_id      = params[:site_id].present? ? params[:site_id].to_i : @user.current_site_id
    filter_type  = params[:filter_type].to_s
    filter_value = params[:filter_value].to_s
    per_page     = [[(params[:per_page] || ASSET_PER_PAGE).to_i, 1].max, 200].min
    page         = [params[:page].to_i, 1].max

    start_date   = params[:start_date].presence&.to_date
    end_date     = params[:end_date].presence&.to_date
    date_range   = asset_date_range(start_date, end_date)

    scope = SiteAsset.where(site_id: site_id)
      .includes(:building, :floor, :unit, :vendor, :asset_group, :qr_code_image)

    scope = scope.where(created_at: date_range) if date_range

    case filter_type
    when "total_assets"
      # no additional filter
    when "assets_in_use"
      scope = scope.where(breakdown: false)
    when "assets_in_breakdown"
      scope = scope.where(breakdown: true)
    when "building"
      scope = scope.joins(:building).where(buildings: { name: filter_value })
    when "floor"
      scope = scope.joins(:floor).where(floors: { name: filter_value })
    when "asset_group"
      scope = scope.joins(:asset_group).where(asset_groups: { name: filter_value })
    when "vendor"
      if filter_value == "No Vendor"
        scope = scope.where(vendor_id: nil)
      else
        scope = scope.joins("LEFT JOIN vendors ON vendors.id = site_assets.vendor_id")
          .where(vendors: { vendor_name: filter_value })
      end
    when "asset_type"
      if filter_value == "Unspecified"
        scope = scope.where("site_assets.asset_type IS NULL OR TRIM(site_assets.asset_type) = ''")
      else
        scope = scope.where(asset_type: filter_value)
      end
    when "category"
      scope = scope.where(category: filter_value)
    when "group_for"
      if filter_value == "Unspecified"
        scope = scope.joins(:asset_group).where("asset_groups.group_for IS NULL OR TRIM(asset_groups.group_for) = ''")
      else
        scope = scope.joins(:asset_group).where(asset_groups: { group_for: filter_value })
      end
    when "breakdown"
      scope = filter_value == "Breakdown" ? scope.where(breakdown: true) : scope.where(breakdown: false)
    when "ppm_scheduled", "ppm_overdue", "ppm_complete",
         "routine_task_scheduled", "routine_task_overdue", "routine_task_complete",
         "activities_performed", "amc_performed",
         "task_status", "status_delay", "assigned_user"
      # These are activity-level filters — handled below
      asset_ids = scope.pluck(:id)
      act_scope = Activity.joins(:checklist).where(asset_id: asset_ids)
      act_scope = act_scope.where(start_time: date_range) if date_range

      case filter_type
      when "ppm_scheduled"
        act_scope = act_scope.where(checklists: { ctype: ['ppm', 'PPM'] }).where(status: 'scheduled')
      when "ppm_overdue"
        act_scope = act_scope.where(checklists: { ctype: ['ppm', 'PPM'] }).where(status: 'overdue')
      when "ppm_complete"
        act_scope = act_scope.where(checklists: { ctype: ['ppm', 'PPM'] }).where(status: 'complete')
      when "routine_task_scheduled"
        act_scope = act_scope.where(checklists: { ctype: 'routine' }).where(status: 'scheduled')
      when "routine_task_overdue"
        act_scope = act_scope.where(checklists: { ctype: 'routine' }).where(status: 'overdue')
      when "routine_task_complete"
        act_scope = act_scope.where(checklists: { ctype: 'routine' }).where(status: 'complete')
      when "activities_performed"
        act_scope = act_scope.where(status: 'complete')
      when "amc_performed"
        act_scope = act_scope.where(checklists: { ctype: 'amc' }).where(status: 'complete')
      end

      case filter_type
      when "task_status"
        act_scope = act_scope.where(status: filter_value)
      when "status_delay"
        act_scope = filter_value == "Delayed" ? act_scope.where("activities.status LIKE '%delay%'") : act_scope.where("activities.status NOT LIKE '%delay%'")
      when "assigned_user"
        if filter_value == "Unassigned"
          act_scope = act_scope.where("activities.assigned_to IS NULL")
        else
          act_scope = act_scope.joins("LEFT JOIN users ON users.id = activities.assigned_to")
            .where("TRIM(CONCAT(COALESCE(users.firstname,''), ' ', COALESCE(users.lastname,''))) = ?", filter_value)
        end
      end

      paginated = act_scope
        .includes(:checklist, :site_asset, :user)
        .order(start_time: :desc)
        .page(page).per(per_page)

      return render json: {
        filter_type:  filter_type,
        filter_value: filter_value,
        count:        paginated.total_count,
        total_pages:  paginated.total_pages,
        current_page: paginated.current_page,
        per_page:     per_page,
        records:      paginated.map { |a| activity_record_details(a) }
      }
    end

    paginated = scope.order(created_at: :desc).page(page).per(per_page)

    render json: {
      filter_type:  filter_type,
      filter_value: filter_value,
      count:        paginated.total_count,
      total_pages:  paginated.total_pages,
      current_page: paginated.current_page,
      per_page:     per_page,
      records:      paginated.map { |a| asset_record_details(a) }
    }
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_site_asset
    @site_asset = SiteAsset.find(params[:id])
  end

  def load_ppm_data
    return unless @site_asset

    now = Time.zone.now
    today_range = now.all_day
    
    ppm_base_scope = @site_asset.activities
      .joins(:checklist)
      .where(checklists: { ctype: 'ppm' })
    
    # Ordered version (for listing)
    ppm_ordered_scope = ppm_base_scope.order(created_at: :desc)
    
    # Paginated list
    @ppm_activities = ppm_ordered_scope.page(params[:activity_page]).per(params[:per_page] || 20)
    
    # Derived lists
    @todays_ppm   = ppm_base_scope.where(start_time: today_range)
    @upcoming_ppm = ppm_base_scope.where(status: "upcoming").page(params[:upcoming_page]).per(params[:per_page] || 20)
    @pending_ppm = ppm_base_scope.where(status: "pending").page(params[:pending_page]).per(params[:per_page] || 20)
    @complete_ppm = ppm_base_scope.where(status: "complete").page(params[:complete_page]).per(params[:per_page] || 20)
    @overdue_ppm = ppm_base_scope.where(status: "overdue").page(params[:overdue_page]).per(params[:per_page] || 20)
    @open_ppm = ppm_base_scope.where(status: "open").page(params[:open_page]).per(params[:per_page] || 20)
    @scheduled_ppm = ppm_base_scope.where(status: "scheduled").page(params[:scheduled_page]).per(params[:per_page] || 20)
    
    # Stats (from full scope)
    grouped = ppm_base_scope.group(:status).count
    total   = grouped.values.sum
    @ppm_stats = {
      total: total,
      complete: grouped['complete'] || 0,
      pending: grouped['pending'] || 0,
      upcoming: grouped['upcoming'] || 0,
      open: grouped['open'] || 0,
      overdue: grouped['overdue'] || 0,
      scheduled: grouped['scheduled'] || 0
    }
  end

  ASSET_PER_PAGE = 10

  def asset_record_details(a)
    {
      id:               a.id,
      name:             a.name,
      serial_number:    a.serial_number,
      model_number:     a.model_number,
      asset_number:     a.asset_number,
      asset_type:       a.asset_type,
      category:         a.category,
      building_name:    a.building&.name,
      floor_name:       a.floor&.name,
      unit_name:        a.unit&.name,
      vendor_name:      a.vendor&.vendor_name || 'No Vendor',
      asset_group_name: a.asset_group&.name,
      breakdown:        a.breakdown,
      critical:         a.critical,
      is_meter:         a.is_meter,
      purchased_on:     a.purchased_on,
      purchase_cost:    a.purchase_cost,
      warranty_expiry:  a.warranty_expiry,
      created_at:       a.created_at
    }
  end

  def activity_record_details(a)
    # binding.pry
    {
      id:              a.id,
      asset_id:        a.asset_id,
      asset_name:      a.site_asset&.name,
      checklist_id:    a.checklist_id,
      checklist_name:  a.checklist&.name,
      checklist_type:  a.checklist&.ctype,
      status:          a.status,
      start_time:      a.start_time,
      end_time:        a.end_time,
      assigned_to:     a.checklist_users.map {|su| su&.user&.full_name}.uniq,
      created_at:      a.created_at
    }
  end

  def build_activity_group(base_scope, filter_type, counts_hash, scope_filter_proc,
                           count_type, count_value, record_page,
                           key_transform: ->(k) { k.to_s })
    result       = {}
    load_records = (count_type == filter_type)

    counts_hash.each do |key, count|
      display_key = key_transform.call(key)

      if load_records && count_value.present? && count_value == display_key
        filtered = scope_filter_proc.call(base_scope, key)
          .includes(:checklist, :site_asset, :user)
          .order(start_time: :desc)
          .page(record_page).per(ASSET_PER_PAGE)
        result[display_key] = {
          count:        count,
          records:      filtered.map { |a| activity_record_details(a) },
          total_pages:  filtered.total_pages,
          current_page: filtered.current_page,
          per_page:     ASSET_PER_PAGE
        }
      else
        result[display_key] = count
      end
    end
    result
  end

  def build_asset_group(base_scope, filter_type, counts_hash, scope_filter_proc,
                        count_type, count_value, record_page,
                        key_transform: ->(k) { k.to_s })
    result       = {}
    load_records = (count_type == filter_type)

    counts_hash.each do |key, count|
      display_key = key_transform.call(key)

      if load_records && count_value.present? && count_value == display_key
        filtered = scope_filter_proc.call(base_scope, key)
          .includes(:building, :floor, :unit, :vendor, :asset_group, :qr_code_image)
          .order(created_at: :desc)
          .page(record_page).per(ASSET_PER_PAGE)
        result[display_key] = {
          count:        count,
          records:      filtered.map { |a| asset_record_details(a) },
          total_pages:  filtered.total_pages,
          current_page: filtered.current_page,
          per_page:     ASSET_PER_PAGE
        }
      else
        result[display_key] = count
      end
    end
    result
  end

  def asset_date_range(start_date, end_date)
    if start_date && end_date
      start_date.beginning_of_day..end_date.end_of_day
    elsif start_date
      start_date.beginning_of_day..start_date.end_of_day
    elsif end_date
      end_date.beginning_of_day..end_date.end_of_day
    end
  end

  # Only allow a list of trusted parameters through.
  def site_asset_params
    params.require(:site_asset).permit(
      :comprehensive, :site_id, :building_id, :floor_id, :unit_id, :name, :serial_number,
      :model_number, :purchased_on, :purchase_cost, :warranty_expiry, :user_id, :equipemnt_id,
      :asset_number, :critical, :breakdown, :is_meter, :parent_asset_id, :active, :description,
      :oem_name, :capacity, :installation, :warranty_start, :remarks, :vendor_id, :asset_group_id,
      :asset_sub_group_id, :uom, :asset_type, :asset_meter_type_id, :longitude, :latitude, :category,
      category_date: {},
      custome_scetions: [],
      asset_params_attributes: [
        :name, :param_type, :dashboard_view, :consumption_view, :order, :digit,
        :alert_below, :alert_above, :min_val, :max_val, :check_prev, :unit_type,
        :multiplier_factor
      ]
    )
  end

  def asset_ppm_data
    {
      site_asset: {
        id: @site_asset.id,
        name: @site_asset.name,
        description: @site_asset.description,
        asset_type: @site_asset.asset_type
      },
      activities: @activities.map do |activity|
        submissions = Submission.where(activity_id: activity.id)
        {
          id: activity.id,
          start_time: activity.start_time,
          end_time: activity.end_time,
          status: activity.status,
          assigned_to: activity.assigned_to,
          assigned_name: assigned_to_name(activity.checklist_users.pluck(:user_id)),
          checklist: activity.checklist ? {
            id: activity.checklist.id,
            name: activity.checklist.name,
            frequency: activity.checklist.frequency
          } : nil,
          activity_log: {
            submissions: submissions.map do |submission|
              question = Question.find_by(id: submission.question_id)
              {
                id: submission.id,
                question: question ? {
                  id: question.id,
                  name: question.name,
                  qtype: question.qtype,
                  group_name: question.try(:group).try(:name),
                  options: [question.option1, question.option2, question.option3, question.option4].compact
                } : nil,
                value: submission.value,
                updated_at: submission.updated_at,
                question_attachments: attachments_for_question(submission)
                # comment: submission.comment
              }
            end
          },
          comment: activity.submissions.first&.comment
        }
      end
    }
  end

  def attachments_for_question(submission)
    attachments = Attachfile.where("relation LIKE ? and relation_id = ?", "Question-#{submission.question_id}", submission.id)
    attachments.map do |doc|
      {
        id: doc.id,
        relation: doc.relation,
        relation_id: doc.relation_id,
        document: doc.document_url
      }
    end
  end

  # Add this method to your controller if it doesn't exist
  def assigned_to_name(user_ids)
    users = User.where(id: user_ids).map(&:full_name)
    users.empty? ? "Unassigned" : users.join(", ")
  end

  def prepare_excel_log_data
    @activities.map do |activity|
      activity_data = {
        'Date' => activity.start_time.strftime("%Y-%m-%d"),
        'Time' => activity.start_time.strftime("%H:%M"),
        'Checklist' => activity.checklist&.name,
        'Status' => activity.status,
        'Assigned To' => activity.user&.full_name
      }

      activity.submissions.each do |submission|
        param = AssetParam.find_by(id: submission.asset_param_id)
        activity_data[param&.name || 'Unknown Param'] = submission.value
      end

      activity_data
    end
  end

  def prepare_excel_all_log_data(activities, site_asset)
    activities.map do |activity|
      submissions = activity.submissions.includes(:question)
      {
        asset_name: site_asset.name,
        asset_type: site_asset.asset_type,
        site_name: site_asset.site&.name,
        site_id: site_asset.site_id,
        building_name: site_asset.building&.name,
        building_id: site_asset.building_id,
        floor_name: site_asset.floor&.name,
        floor_id: site_asset.floor_id,
        unit_name: site_asset.unit&.name,
        unit_id: site_asset.unit_id,
        serial_number: site_asset.serial_number,
        model_number: site_asset.model_number,
        purchased_on: site_asset.purchased_on,
        purchase_cost: site_asset.purchase_cost,
        warranty_expiry: site_asset.warranty_expiry,
        critical: site_asset.critical,
        breakdown: site_asset.breakdown,
        is_meter: site_asset.is_meter,
        parent_asset_id: site_asset.parent_asset_id,
        active: site_asset.active,
        description: site_asset.description,
        oem_name: site_asset.oem_name,
        capacity: site_asset.capacity,
        installation: site_asset.installation,
        warranty_start: site_asset.warranty_start,
        remarks: site_asset.remarks,
        vendor_id: site_asset.vendor_id,
        vendor_name: Vendor.find_by(id: site_asset.vendor_id)&.vendor_name,
        asset_group_id: site_asset.asset_group_id,
        asset_group_name: AssetGroup.find_by(id: site_asset.asset_group_id)&.name,
        # asset_sub_group_id: site_asset.asset_sub_group_id,
        # asset_sub_group_name: site_asset.asset_sub_group&.name,
        uom: site_asset.uom,
        activity_id: activity.id,
        start_time: activity.start_time&.strftime("%Y-%m-%d %H:%M:%S"),
        end_time: activity.end_time&.strftime("%Y-%m-%d %H:%M:%S"),
        status: activity.status,
        checklist_name: activity.checklist&.name,
        checklist_frequency: activity.checklist&.frequency,
        checklist_start_date: activity.checklist&.start_date,
        checklist_end_date: activity.checklist&.end_date,
        checklist_occurs: activity.checklist&.occurs,
        checklist_type: activity.checklist&.ctype,
        performed_by: activity.user&.full_name || "Unassigned",
        assigned_to: User.find_by(id: activity.assigned_to)&.full_name || "Unassigned",
        total_questions_performed: activity.submissions.count,
        submissions: submissions.map do |submission|
          {
            question: submission.question&.name,
            answer: submission.value,
            comment: submission.comment,
            updated_at: submission.updated_at&.strftime("%Y-%m-%d %H:%M:%S")
          }
        end
      }
    end
  end

  # Parses MM/DD/YYYY, DD/MM/YYYY, YYYY-MM-DD, and other common formats
  def parse_export_date(value)
    return nil if value.blank?

    formats = ["%m/%d/%Y", "%d/%m/%Y", "%Y-%m-%d", "%d-%m-%Y", "%m-%d-%Y"]
    formats.each do |fmt|
      return Date.strptime(value, fmt)
    rescue Date::Error
      next
    end

    Date.parse(value) rescue nil
  end

end
