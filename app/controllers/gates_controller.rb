class GatesController < ApplicationController
  before_action :set_gate, only: %i[ show edit update destroy ]

  # GET /gates or /gates.json
  def index
    @gates = Gate.all
  end

  # GET /gates/1 or /gates/1.json
  def show
  end

  # GET /gates/new
  def new
    @gate = Gate.new
  end

  # GET /gates/1/edit
  def edit
  end

  # POST /gates or /gates.json
  def create
    @gate = Gate.new(gate_params)

    respond_to do |format|
      if @gate.save
        format.html { redirect_to @gate, notice: "Gate was successfully created." }
        format.json { render :show, status: :created, location: @gate }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @gate.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /gates/1 or /gates/1.json
  def update
    respond_to do |format|
      if @gate.update(gate_params)
        format.html { redirect_to @gate, notice: "Gate was successfully updated." }
        format.json { render :show, status: :ok, location: @gate }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @gate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gates/1 or /gates/1.json
  def destroy
    @gate.destroy
    respond_to do |format|
      format.html { redirect_to gates_url, notice: "Gate was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gate
      @gate = Gate.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def gate_params
      params.require(:gate).permit(:name, :site_id, :user_id, :created_by_id)
    end
end
