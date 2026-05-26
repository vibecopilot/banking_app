class IncidentInjuriesController < ApplicationController
  before_action :set_incident_injury, only: %i[ show edit update destroy ]

  # GET /incident_injuries or /incident_injuries.json
  def index
    @incident_injuries = IncidentInjury.all
  end

  # GET /incident_injuries/1 or /incident_injuries/1.json
  def show
  end

  # GET /incident_injuries/new
  def new
    @incident_injury = IncidentInjury.new
  end

  # GET /incident_injuries/1/edit
  def edit
  end

  # POST /incident_injuries or /incident_injuries.json
  def create
    inc_injuries = []
    
    if params[:injuries].present?
      # Loop through each injury in the array and create it
      params[:injuries].each do |inj|
        if inj[:injury_type].present?
          # Create each injury and add it to the inc_injuries array
          injury = IncidentInjury.create!(incident_id: params[:incident_id], injury_type: inj[:injury_type], injury_number: inj[:injury_number], lost_time: inj[:lost_time], who_got_injured_id: inj[:who_got_injured_id], who_got_injured: inj[:who_got_injured], name: inj[:name], mobile: inj[:mobile], company_name: inj[:company_name])
          inc_injuries << injury
        end
      end

      # Respond with multiple injuries created
      respond_to do |format|
        format.json { render json: inc_injuries, status: :created }
      end
    else
      # Handle creating a single record
      @incident_injury = IncidentInjury.new(incident_injury_params)

      respond_to do |format|
        if @incident_injury.save
          format.html { redirect_to @incident_injury, notice: "Incident injury was successfully created." }
          format.json { render :show, status: :created, location: @incident_injury }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @incident_injury.errors, status: :unprocessable_entity }
        end
      end
    end
  end


  # PATCH/PUT /incident_injuries/1 or /incident_injuries/1.json
  def update
    respond_to do |format|
      if @incident_injury.update(incident_injury_params)
        format.html { redirect_to @incident_injury, notice: "Incident injury was successfully updated." }
        format.json { render :show, status: :ok, location: @incident_injury }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @incident_injury.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /incident_injuries/1 or /incident_injuries/1.json
  def destroy
    @incident_injury.destroy
    respond_to do |format|
      format.html { redirect_to incident_injuries_url, notice: "Incident injury was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_incident_injury
      @incident_injury = IncidentInjury.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def incident_injury_params
      params.require(:incident_injury).permit(:injury_type, :injury_number, :incident_id, :lost_time, :who_got_injured_id, :who_got_injured, :name, :company_name, :mobile)
    end
end
