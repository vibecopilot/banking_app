class SitesController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_site, only: %i[ show edit update destroy toggle_active ]

  # GET /sites or /sites.json
  def index
    #@sites = Site.where(id: @user.user_sites.pluck(:site_id))
    @sites = Site.where(id: @user.user_sites.pluck(:site_id))
  end

  def setup
  end

  # GET /sites/1 or /sites/1.json
  def show
  end

  def add_company
    @company = Company.create(name: params[:company][:name], created_by: @user.id)
    render json: @company
  end

  def add_company_by_organization
    @company = Company.create(name: params[:company][:name], created_by: @user.id, organization_id: params[:company][:organization_id])
    render json: @company
  end

  def company_list
    @company_list = Company.all
    render json: @company_list
  end

  # GET /sites/new
  def new
    @site = Site.new
  end

  # GET /sites/1/edit
  def edit
  end

  def import
    @file = params[:file]
    @uploadds = Site.import(@file, @user)
    respond_to do |format|
      format.html {
        redirect_to request.referrer + "#" , notice: "Successfully imported Sites"
      }
      format.json { render json: @uploadds }
    end
  end

  # POST /sites or /sites.json
  def create
    @site = Site.new(site_params)

    respond_to do |format|
      if @site.save
        params[:features].each do |f|
          @site.features.create(feature_name: f, created_by: @user.id)
        end
        UserSite.create(user_id: @user.id, site_id: @site.id)
        format.html { redirect_to "/sites", notice: "Site was successfully created." }
        format.json { render :show, status: :created, location: @site }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sites/1 or /sites/1.json

  def update
    respond_to do |format|
      if @site.update(site_params)
        @site.features.delete_all if params[:features].present?
        if params[:features].present?
          params[:features].each do |f|
            @site.features.create(feature_name: f, created_by: @user.id)
          end
        end
        format.html { redirect_to params[:redirect_url] || @site, notice: "Site was successfully updated." }
        format.json { render :show, status: :ok, location: @site }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  def toggle_active
    @site.update(active: !@site.active)
    respond_to do |format|
      format.html { redirect_to sites_path, notice: "Site status was successfully updated." }
      format.json { render json: { success: true, active: @site.active } }
    end
  end

  def operation_days
    @site = Site.find_by(id: params[:id])

    if @site.nil?
      respond_to do |format|
        format.json { render json: { error: "Site not found" }, status: :not_found }
      end
    else
      respond_to do |format|
        if @site.update(site_params)
          format.json { render :show, status: :ok, location: @site }
        else
          format.json { render json: @site.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def company_sites
    @sites = Site.where(company_id: params[:company_id])
    if params[:q].present?
      @sites = @sites.where("name LIKE ?", "%#{params[:q]}%")
    end

    render json: {
      sites: @sites.select(:id, :name, :region).map do |site|
        {
          id: site.id,
          name: site.name,
          region: site.region,
        }
      end
    }
  end

  def features
    @features = Feature.where(site_id: @user.current_site_id)
    render json: @features
  end

  def all_features
    @all_features = Feature.all
    render json: @all_features
  end

  def consumption
    if params[:q].present? && params[:q][:date_range].present?
      @date_range = params[:q][:date_range].split(" - ")
      params[:q][:created_at_lteq] = Date.strptime(@date_range[1], "%d/%m/%Y")
      params[:q][:created_at_gteq] = Date.strptime(@date_range[0], "%d/%m/%Y")
    else
      params[:q] = params[:q].present? ? params[:q] : {created_at_gteq: Date.today.beginning_of_month, created_at_lteq: Date.today.end_of_month}
      params[:q][:date_range] = "#{params[:q][:created_at_gteq].strftime('%d/%m/%Y')} - #{params[:q][:created_at_lteq].strftime('%d/%m/%Y')}"
    end

    # @sites = @user.sites.ransack(params[:w]).result
    @sites = Site.where(id: @user.current_site_id)
    @siteids = @sites.pluck(:id)
    @assets_params = AssetParam.ransack(site_asset_site_id_in: @siteids, consumption_view_eq: 1).result
    @asset_with_params = @assets_params.pluck(:asset_id).uniq
    respond_to do |format|
      format.xlsx {
        response.headers[
          'Content-Disposition'
        ] = "attachment; filename=consumption.xlsx"
      }
      format.html { render :consumption}
    end

  end

  def reports
    # @project_id = params[:project_id] || @projects.first.id
    if params[:q].present? && params[:q][:date_range].present?
      @date_range = params[:q][:date_range].split(" - ")
      params[:q][:created_at_lteq] = Date.strptime(@date_range[1], "%d/%m/%Y").strftime("%d/%m/%Y")
      params[:q][:created_at_gteq] = Date.strptime(@date_range[0], "%d/%m/%Y").strftime("%d/%m/%Y")
    else
      params[:q] = params[:q].present? ? params[:q] : {created_at_gteq: Date.today.beginning_of_month.strftime('%d/%m/%Y'), created_at_lteq: Date.today.end_of_month.strftime('%d/%m/%Y')}
      params[:q][:date_range] = "#{params[:q][:created_at_gteq]} - #{params[:q][:created_at_lteq]}"
    end
    params[:w] = params[:w].present? ? params[:w] : {id_in: [@user.current_site_id]}
    @date1 = params[:q][:created_at_gteq].to_date
    @date2 = params[:q][:created_at_lteq].to_date
    @sites = @user.sites.ransack(params[:w]).result
    @siteids = @sites.pluck(:id)
    @companies = Company.where(id: @sites.pluck(:company_id))
    oparams = params
    @complaints = Complaint.where(site_id: @siteids).ransack(params[:q]).result
    @last_week_complaints = @complaints
    @top_c = @complaints.group(:category_type_id).count
    @top_categories = HelpdeskCategory.where(id:  @top_c.sort_by { |e| e[1]  }.reverse.map { |e| e[0] })
    @assets = SiteAsset.where(site_id: @siteids)
    @occurrences = Activity.ransack(checklist_site_id_in: @siteids).result
    @checklists = Checklist.ransack(site_id_in: @siteids).result


    @highchart_category_data_array = []
    @categorywise_drilldown = []
    @issue_types = ComplaintStatus.where(society_id: @siteids).pluck(:name).uniq
    htcgs = HelpdeskCategory.where(society_id: @siteids).pluck(:name).uniq
    @issue_types.each do |it|
      basehash = Hash.new
      basehash[:name] = it
      basehash[:y] = @complaints.ransack(complaint_status_name_eq: it).result.count
      basehash[:drilldown] = "#{it}"

      sample = Hash.new
      sample["name"] = "#{it}"
      sample["id"] = "#{it}"
      sample["data"] = []
      @category_count_including_zero = htcgs.map{|s|
        ct = @complaints.ransack(complaint_status_name_eq: it, category_type_name: s).result.count
        if ct > 0
          sample["data"] << ["#{s}" ,ct]
        end
      }

      @categorywise_drilldown << sample
      @highchart_category_data_array << basehash
    end


    @highchart_category_data_array2 = []
    @categorywise_drilldown2 = []
    basehash = Hash.new
    basehash[:name] = "Response Breached"
    basehash[:y] = @complaints.ransack(response_breached_eq: true).result.count
    basehash[:drilldown] = "ResponseBreached"

    sample = Hash.new
    sample["name"] = "Response Breached"
    sample["id"] = "ResponseBreached"
    sample["data"] = []
    @category_count_including_zero = htcgs.map{|s|
      ct = @complaints.ransack(response_breached_eq: true, category_type_name_eq: s).result.count
      if ct > 0
        sample["data"] << ["#{s}" ,ct]
      end
    }
    @categorywise_drilldown2 << sample
    @highchart_category_data_array2 << basehash

    basehash = Hash.new
    basehash[:name] = "Response Achieved"
    basehash[:y] = @complaints.ransack(response_breached_eq: false).result.count
    basehash[:drilldown] = "ResponseAchieved"

    sample = Hash.new
    sample["name"] = "Response Achieved"
    sample["id"] = "ResponseAchieved"
    sample["data"] = []
    @category_count_including_zero = htcgs.map{|s|
      ct = @complaints.ransack(response_breached_eq: false, category_type_name_eq: s).result.count
      if ct > 0
        sample["data"] << ["#{s}" ,ct]
      end
    }
    @categorywise_drilldown2 << sample
    @highchart_category_data_array2 << basehash


    basehash = Hash.new
    basehash[:name] = "Resolution Breached"
    basehash[:y] = @complaints.ransack(resolution_breached_eq: true).result.count
    basehash[:drilldown] = "ResolutionBreached"

    sample = Hash.new
    sample["name"] = "Resolution Breached"
    sample["id"] = "ResolutionBreached"
    sample["data"] = []
    @category_count_including_zero = htcgs.map{|s|
      ct = @complaints.ransack(resolution_breached_eq: true, category_type_name_eq: s).result.count
      if ct > 0
        sample["data"] << ["#{s}" ,ct]
      end
    }
    @categorywise_drilldown2 << sample
    @highchart_category_data_array2 << basehash

    basehash = Hash.new
    basehash[:name] = "Resolution Achieved"
    basehash[:y] = @complaints.ransack(resolution_breached_eq: false).result.count
    basehash[:drilldown] = "ResolutionAchieved"

    sample = Hash.new
    sample["name"] = "Resolution Achieved"
    sample["id"] = "ResolutionAchieved"
    sample["data"] = []
    @category_count_including_zero = htcgs.map{|s|
      ct = @complaints.ransack(resolution_breached_eq: false, category_type_name_eq: s).result.count
      if ct > 0
        sample["data"] << ["#{s}" ,ct]
      end
    }
    @categorywise_drilldown2 << sample
    @highchart_category_data_array2 << basehash


    @highchart_category_data_array3 = []
    @categorywise_drilldown3 = []
    basehash = Hash.new
    basehash[:name] = "In Use"
    basehash[:y] = @assets.ransack(breakdown_eq: false).result.count
    basehash[:drilldown] = "InUse"

    sample = Hash.new
    sample["name"] = "Critical"
    sample["id"] = "InUse"
    sample["data"] = []
    sample["data"] << {name: "Critical" , y: @assets.ransack(breakdown_eq: false, critical_eq: true).result.count, drilldown: "critical_inuse"}
    sample["data"] << {name: "Non Critical" , y: @assets.ransack(breakdown_eq: false, critical_eq: false).result.count, drilldown: "non_critical_inuse"}

    @categorywise_drilldown3 << sample

    sample = Hash.new
    sample["name"] = "Critical InUse"
    sample["id"] = "critical_inuse"
    sample["data"] = @assets.ransack(breakdown_eq: false, critical_eq: true).result.map { |e| {name: e.name, y: 1}  }
    @categorywise_drilldown3 << sample

    sample = Hash.new
    sample["name"] = "Non Critical InUse"
    sample["id"] = "non_critical_inuse"
    sample["data"] = @assets.ransack(breakdown_eq: false, critical_eq: false).result.map { |e| {name: e.name, y: 1}  }
    @categorywise_drilldown3 << sample


    @highchart_category_data_array3 << basehash

    basehash = Hash.new
    basehash[:name] = "Breakdown"
    basehash[:y] = @assets.ransack(breakdown_eq: true).result.count
    basehash[:drilldown] = "Breakdown"

    sample = Hash.new
    sample["name"] = "Critical"
    sample["id"] = "Breakdown"
    sample["data"] = []
    sample["data"] << {name: "Critical", y: @assets.ransack(breakdown_eq: true, critical_eq: true).result.count, drilldown: "critical_Breakdown"}
    sample["data"] << {name: "Non Critical", y: @assets.ransack(breakdown_eq: true, critical_eq: false).result.count, drilldown: "non_critical_Breakdown"}

    @categorywise_drilldown3 << sample
    sample = Hash.new
    sample["name"] = "Critical Breakdown"
    sample["id"] = "critical_Breakdown"
    sample["data"] = @assets.ransack(breakdown_eq: true, critical_eq: true).result.map { |e| {name: e.name, y: 1}  }
    @categorywise_drilldown3 << sample

    sample = Hash.new
    sample["name"] = "Non Critical Breakdown"
    sample["id"] = "non_critical_Breakdown"
    sample["data"] = @assets.ransack(breakdown_eq: true, critical_eq: false).result.map { |e| {name: e.name, y: 1}  }
    @categorywise_drilldown3 << sample


    @highchart_category_data_array3 << basehash


    @highchart_category_data_array4 = []
    @categorywise_drilldown4 = []
    @checklist_names = @checklists.pluck(:name).uniq
    ["open", "complete", "overdue", "upcoming"].each { |e|
      basehash = Hash.new
      basehash[:name] = e
      basehash[:y] = @occurrences.ransack(status_eq: e).result.count
      basehash[:drilldown] = e

      sample = Hash.new
      sample["name"] = "#{e}"
      sample["id"] = e
      sample["data"] = []
      @checklist_names.map{|s|
        ct = @occurrences.ransack(status_eq: e, checklist_name_eq: s).result.count
        if ct > 0
          sample["data"] << ["#{s}" ,ct]
        end
      }
      @categorywise_drilldown4 << sample
      @highchart_category_data_array4 << basehash
    }
    @assets_params = AssetParam.ransack(site_asset_site_id_in: @siteids, dashboard_view_eq: 1).result
    @asset_with_params = @assets_params.pluck(:asset_id).uniq
  end


  # DELETE /sites/1 or /sites/1.json
  def destroy
    @site.destroy
    respond_to do |format|
      format.html { redirect_to sites_url, notice: "Site was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_site
    @site = Site.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def site_params
    params.require(:site).permit(:company_id, :name, :account_id, :region, :active, :longitude, :latitude, :radius, helpdesk_operations_attributes: [:id, :op_of, :op_of_id, :dayofweek, :start_hour, :start_min, :end_hour, :end_min, :is_open, :active, :of_phase])
  end
end
