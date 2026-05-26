class AmenityBookingRulesController < ApplicationController
  before_action :set_amenity_booking_rule, only: %i[ show edit update destroy ]

  # GET /amenity_booking_rules or /amenity_booking_rules.json
  def index
    @amenity_booking_rules = AmenityBookingRule.all
  end

  # GET /amenity_booking_rules/1 or /amenity_booking_rules/1.json
  def show
  end

  # GET /amenity_booking_rules/new
  def new
    @amenity_booking_rule = AmenityBookingRule.new
  end

  # GET /amenity_booking_rules/1/edit
  def edit
  end

  # POST /amenity_booking_rules or /amenity_booking_rules.json
  def create
    @amenity_booking_rule = AmenityBookingRule.new(amenity_booking_rule_params)

    respond_to do |format|
      if @amenity_booking_rule.save
        format.html { redirect_to @amenity_booking_rule, notice: "Amenity booking rule was successfully created." }
        format.json { render :show, status: :created, location: @amenity_booking_rule }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @amenity_booking_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /amenity_booking_rules/1 or /amenity_booking_rules/1.json
  def update
    respond_to do |format|
      if @amenity_booking_rule.update(amenity_booking_rule_params)
        format.html { redirect_to @amenity_booking_rule, notice: "Amenity booking rule was successfully updated." }
        format.json { render :show, status: :ok, location: @amenity_booking_rule }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @amenity_booking_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /amenity_booking_rules/1 or /amenity_booking_rules/1.json
  def destroy
    @amenity_booking_rule.destroy
    respond_to do |format|
      format.html { redirect_to amenity_booking_rules_url, notice: "Amenity booking rule was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_amenity_booking_rule
      @amenity_booking_rule = AmenityBookingRule.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def amenity_booking_rule_params
      params.require(:amenity_booking_rule).permit(:enumerator, :duration, :level, :active, :amenity_id, :site_id, :facility_can_be_booked, :times_per_day, :period_type,
        prime_times_attributes: [:id, :amenity_booking_rules_id, :start_time, :end_time]
        )
    end
end
