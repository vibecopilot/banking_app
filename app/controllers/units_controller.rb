class UnitsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_unit, only: %i[ show edit update destroy ]

  # GET /units or /units.json
  def index
    @units = Unit.where(site_id: @user.current_site_id)
    .includes(:building, :floor, :site, :unit_configuration)
    .ransack(params[:q]).result
    respond_to do |format|
      format.html
      format.json do
        if params[:mob].present?
          render json: {"units": @units}
        else
          render 'index'
        end
      end
    end
  end

  # GET /units/1 or /units/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render 'show' }
    end
  end

  # GET /units/new
  def new
    #@unit = Unit.new
    @unit = Unit.new
  end

  # GET /units/1/edit
  def edit
  end

  def user_units
    # Handle both URL formats:
    # /units/user_units.json?user_id=733
    # /units/user_units/733.json
    user_id = params[:user_id] || params[:id]

    unless user_id.present?
      return render json: { error: "user_id parameter is required" }, status: :bad_request
    end

    user = User.find_by(id: user_id)
    unless user
      return render json: { error: "User not found" }, status: :not_found
    end

    # Get units from user_sites (primary method)
    user_site_units = Unit.joins("JOIN user_sites ON user_sites.unit_id = units.id")
    .where("user_sites.user_id = ?", user_id)
    .includes(:building, :floor, :site, :unit_configuration)

    # Get direct unit assignment (fallback method)
    direct_unit = user.unit ? [user.unit] : []

    # Combine both methods and remove duplicates
    all_units = (user_site_units.to_a + direct_unit).uniq

    units_data = all_units.map do |unit|
      {
        id: unit.id,
        name: unit.name,
        unit_configuration_id: unit.unit_configuration_id,
        unit_configuration_name: unit.unit_configuration&.name,
        building: {
          id: unit.building&.id,
          name: unit.building&.name
        },
        floor: {
          id: unit.floor&.id,
          name: unit.floor&.name
        },
        site: {
          id: unit.site&.id,
          name: unit.site&.name
        }
      }
    end

    respond_to do |format|
      format.json do
        render json: {
          user: {
            id: user.id,
            email: user.email,
            name: "#{user.firstname} #{user.lastname}"
          },
          units: units_data,
          total_units: units_data.count
        }
      end
    end
  end

  def create_user_site
    user_id = params[:user_id]
    unit_id = params[:unit_id]
    site_id = params[:site_id]

    unless user_id.present? && unit_id.present? && site_id.present?
      return render json: {
        error: "user_id, unit_id, and site_id parameters are required"
      }, status: :bad_request
    end

    user = User.find_by(id: user_id)
    unless user
      return render json: { error: "User not found" }, status: :not_found
    end

    unit = Unit.find_by(id: unit_id)
    unless unit
      return render json: { error: "Unit not found" }, status: :not_found
    end

    site = Site.find_by(id: site_id)
    unless site
      return render json: { error: "Site not found" }, status: :not_found
    end

    # Check if user_site already exists
    existing_user_site = UserSite.find_by(user_id: user_id, unit_id: unit_id, site_id: site_id)
    if existing_user_site
      return render json: {
        error: "User is already associated with this unit",
        user_site: existing_user_site.as_json(include: [:site, :unit])
      }, status: :unprocessable_entity
    end

    # Create new user_site
    user_site_params = {
      user_id: user_id,
      unit_id: unit_id,
      site_id: site_id,
      ownership: params[:ownership] || "resident",
      ownership_type: params[:ownership_type] || "primary",
      lives_here: params[:lives_here] || true,
      is_approved: params[:is_approved] || false
    }

    user_site = UserSite.new(user_site_params)

    if user_site.save
      # Load the created user_site with associations
      created_user_site = UserSite.includes(:site, :unit => [:building, :floor]).find(user_site.id)

      render json: {
        success: true,
        message: "User site association created successfully",
        user_site: {
          id: created_user_site.id,
          user_id: created_user_site.user_id,
          unit_id: created_user_site.unit_id,
          site_id: created_user_site.site_id,
          ownership: created_user_site.ownership,
          ownership_type: created_user_site.ownership_type,
          lives_here: created_user_site.lives_here,
          is_approved: created_user_site.is_approved,
          created_at: created_user_site.created_at,
          updated_at: created_user_site.updated_at,
          user: {
            id: user.id,
            firstname: user.firstname,
            lastname: user.lastname,
            email: user.email
          },
          unit: {
            id: created_user_site.unit.id,
            name: created_user_site.unit.name,
            building: {
              id: created_user_site.unit.building&.id,
              name: created_user_site.unit.building&.name
            },
            floor: {
              id: created_user_site.unit.floor&.id,
              name: created_user_site.unit.floor&.name
            }
          },
          site: {
            id: created_user_site.site.id,
            name: created_user_site.site.name
          }
        }
      }, status: :created
    else
      render json: {
        error: "Failed to create user site association",
        errors: user_site.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def create_multiple_user_sites
    user_sites_data = params[:user_sites]

    unless user_sites_data.present? && user_sites_data.is_a?(Array)
      return render json: {
        error: "user_sites parameter is required and must be an array"
      }, status: :bad_request
    end

    created_user_sites = []
    errors = []

    user_sites_data.each_with_index do |user_site_params, index|
      begin
        user_id = user_site_params[:user_id]
        unit_id = user_site_params[:unit_id]
        site_id = user_site_params[:site_id]

        # Validate required parameters
        unless user_id.present? && unit_id.present? && site_id.present?
          errors << {
            index: index,
            error: "user_id, unit_id, and site_id are required",
            data: user_site_params
          }
          next
        end

        # Check if user exists
        user = User.find_by(id: user_id)
        unless user
          errors << {
            index: index,
            error: "User not found",
            user_id: user_id,
            data: user_site_params
          }
          next
        end

        # Check if unit exists
        unit = Unit.find_by(id: unit_id)
        unless unit
          errors << {
            index: index,
            error: "Unit not found",
            unit_id: unit_id,
            data: user_site_params
          }
          next
        end

        # Check if site exists
        site = Site.find_by(id: site_id)
        unless site
          errors << {
            index: index,
            error: "Site not found",
            site_id: site_id,
            data: user_site_params
          }
          next
        end

        # Check if user_site already exists
        existing_user_site = UserSite.find_by(user_id: user_id, unit_id: unit_id, site_id: site_id)
        if existing_user_site
          errors << {
            index: index,
            error: "User is already associated with this unit",
            existing_user_site_id: existing_user_site.id,
            data: user_site_params
          }
          next
        end

        # Create new user_site
        new_user_site_params = {
          user_id: user_id,
          unit_id: unit_id,
          site_id: site_id,
          ownership: user_site_params[:ownership] || "resident",
          ownership_type: user_site_params[:ownership_type] || "primary",
          lives_here: user_site_params.has_key?(:lives_here) ? user_site_params[:lives_here] : true,
          is_approved: user_site_params.has_key?(:is_approved) ? user_site_params[:is_approved] : false
        }

        user_site = UserSite.new(new_user_site_params)

        if user_site.save
          # Load the created user_site with associations
          created_user_site = UserSite.includes(:site, {:unit => [:building, :floor]}, :user).find(user_site.id)

          created_user_sites << {
            index: index,
            id: created_user_site.id,
            user_id: created_user_site.user_id,
            unit_id: created_user_site.unit_id,
            site_id: created_user_site.site_id,
            ownership: created_user_site.ownership,
            ownership_type: created_user_site.ownership_type,
            lives_here: created_user_site.lives_here,
            is_approved: created_user_site.is_approved,
            created_at: created_user_site.created_at,
            user: {
              id: created_user_site.user.id,
              firstname: created_user_site.user.firstname,
              lastname: created_user_site.user.lastname,
              email: created_user_site.user.email
            },
            unit: {
              id: created_user_site.unit.id,
              name: created_user_site.unit.name,
              building: {
                id: created_user_site.unit.building&.id,
                name: created_user_site.unit.building&.name
              },
              floor: {
                id: created_user_site.unit.floor&.id,
                name: created_user_site.unit.floor&.name
              }
            },
            site: {
              id: created_user_site.site.id,
              name: created_user_site.site.name
            }
          }
        else
          errors << {
            index: index,
            error: "Failed to create user site association",
            validation_errors: user_site.errors.full_messages,
            data: user_site_params
          }
        end

      rescue => e
        errors << {
          index: index,
          error: "Unexpected error: #{e.message}",
          data: user_site_params
        }
      end
    end

    # Determine response status
    if created_user_sites.any? && errors.empty?
      status = :created
      message = "All user site associations created successfully"
    elsif created_user_sites.any? && errors.any?
      status = :multi_status
      message = "Some user site associations created successfully, some failed"
    else
      status = :unprocessable_entity
      message = "Failed to create any user site associations"
    end

    render json: {
      success: created_user_sites.any?,
      message: message,
      total_requested: user_sites_data.count,
      total_created: created_user_sites.count,
      total_errors: errors.count,
      created_user_sites: created_user_sites,
      errors: errors
    }, status: status
  end

  def update_user_site
    user_site_id = params[:user_site_id]

    unless user_site_id.present?
      return render json: { error: "user_site_id parameter is required" }, status: :bad_request
    end

    user_site = UserSite.find_by(id: user_site_id)
    unless user_site
      return render json: { error: "User site association not found" }, status: :not_found
    end

    # Allowed parameters for update
    update_params = {}
    update_params[:ownership] = params[:ownership] if params[:ownership].present?
    update_params[:ownership_type] = params[:ownership_type] if params[:ownership_type].present?
    update_params[:lives_here] = params[:lives_here] if params.has_key?(:lives_here)
    update_params[:is_approved] = params[:is_approved] if params.has_key?(:is_approved)

    if user_site.update(update_params)
      # Load the updated user_site with associations
      updated_user_site = UserSite.includes(:site, {:unit => [:building, :floor]}, :user).find(user_site.id)

      render json: {
        success: true,
        message: "User site association updated successfully",
        user_site: {
          id: updated_user_site.id,
          user_id: updated_user_site.user_id,
          unit_id: updated_user_site.unit_id,
          site_id: updated_user_site.site_id,
          ownership: updated_user_site.ownership,
          ownership_type: updated_user_site.ownership_type,
          lives_here: updated_user_site.lives_here,
          is_approved: updated_user_site.is_approved,
          updated_at: updated_user_site.updated_at,
          user: {
            id: updated_user_site.user.id,
            firstname: updated_user_site.user.firstname,
            lastname: updated_user_site.user.lastname,
            email: updated_user_site.user.email
          },
          unit: {
            id: updated_user_site.unit.id,
            name: updated_user_site.unit.name,
            building: {
              id: updated_user_site.unit.building&.id,
              name: updated_user_site.unit.building&.name
            },
            floor: {
              id: updated_user_site.unit.floor&.id,
              name: updated_user_site.unit.floor&.name
            }
          },
          site: {
            id: updated_user_site.site.id,
            name: updated_user_site.site.name
          }
        }
      }
    else
      render json: {
        error: "Failed to update user site association",
        errors: user_site.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def delete_user_site
    user_site_id = params[:user_site_id]

    unless user_site_id.present?
      return render json: { error: "user_site_id parameter is required" }, status: :bad_request
    end

    user_site = UserSite.find_by(id: user_site_id)
    unless user_site
      return render json: { error: "User site association not found" }, status: :not_found
    end

    # Store user_site info before deletion
    user_site_info = {
      id: user_site.id,
      user_id: user_site.user_id,
      unit_id: user_site.unit_id,
      site_id: user_site.site_id,
      ownership: user_site.ownership,
      ownership_type: user_site.ownership_type
    }

    if user_site.destroy
      render json: {
        success: true,
        message: "User site association deleted successfully",
        deleted_user_site: user_site_info
      }
    else
      render json: {
        error: "Failed to delete user site association",
        errors: user_site.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def import
    @file = params[:file]
    @uploadds = Unit.import(@file, @user)
    respond_to do |format|
      format.html {
        redirect_to request.referrer + "#" , notice: "Successfully imported units"
      }
      format.json { render json: @uploadds }
    end
  end

  # POST /units or /units.json
  def create
    @unit = Unit.new(unit_params)

    respond_to do |format|
      if @unit.save
        format.html { redirect_to "/units", notice: "Unit was successfully created." }
        format.json { render :show, status: :created, location: @unit }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /units/1 or /units/1.json
  def update
    respond_to do |format|
      if @unit.update(unit_params)
        format.html { redirect_to @unit, notice: "Unit was successfully updated." }
        format.json { render :show, status: :ok, location: @unit }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /units/1 or /units/1.json
  def destroy
    @unit.destroy
    respond_to do |format|
      format.html { redirect_to units_url, notice: "Unit was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_unit
    @unit = Unit.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def unit_params
    params.require(:unit).permit(:name, :site_id, :floor_id, :building_id, :unit_configuration_id)
  end
end
